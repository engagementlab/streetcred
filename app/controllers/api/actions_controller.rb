class API::ActionsController < ApplicationController
  require 'mail'
  skip_before_filter :verify_authenticity_token
  respond_to :json, :html

  def index
    @actions = Action.desc(:created_at)
  end
  
  # Generic create method.  Automatically creates User; ActionType and Channel must already exist (no auto-create)
  def create
    if params['email'].present?

      @user = User.where(email: params['email']).first_or_initialize
      # Create a User with a random password if @user doesn't yet exist
      create_devise_user(@user) unless @user.persisted?

      # Find Channel and ActionType
      channel = Channel.where(api_key: params['api_key']).first
      action_type = ActionType.where(channel_id: channel.id).where(name: params['action_type']).first

      if channel.present? && action_type.present?
        action = Action.new(params[:action])
        action.user_id = @user.id
        action.action_type_id = action_type.id
        action.save
      end
      @completed_campaigns = @user.campaigns_completed_by_action(action)
      NotificationMailer.status_email(@user, action).deliver
      respond_with(@completed_campaigns)
    end
  end

  # Incoming email sent to 'reports@streetcred.us' and routed through CloudMailIn (Heroku Add-On)
  # Automatically creates User; Channel and ActionType must already exist (no auto-create)
  def email
    message = Mail.new(params)

    if message.present?
      @user = User.where(email: message.from.first).first_or_initialize
      # Create a User with a random password if @user doesn't yet exist
      create_devise_user(@user) unless @user.persisted?

      # Find Channel and ActionType
      channel = Channel.where(name: 'Email').first
      action_type = ActionType.where(channel_id: channel.id).where(provider_uid: message.subject.try(:strip)).first

      if channel.present? && action_type.present?
        action = @user.actions.create(
          action_type_id: action_type.id, 
          api_key: channel.api_key,
          timestamp: message.date
        )
        @completed_campaigns = @user.campaigns_completed_by_action(action)
        @in_progress_campaigns = @user.campaigns_in_progress_by_action(action)
        if @in_progress_campaigns.present? || @completed_campaigns.present?
          NotificationMailer.status_email(@user, action).deliver
        end
        render nothing: true, status: 200
      else
        logger.info "********** No matching ActionType found **********"
        render nothing: true, status: 200
      end
    else
      logger.info "********** No from address **********"
      render nothing: true, status: 500
    end
  end
  
  # incoming checkins from the Fourquuare Push API - https://developer.foursquare.com/overview/realtime
  # note: users must OAuth into their Foursquare account form StreeCred to enable checkin push
  def foursquare
    if params['secret'] == ENV['FOURSQUARE_PUSH_SECRET'] # 'BOL410IIRYOQ1FEAYT1PZYGYDVN5OYUYI1JO5CI2SW3UNO20'
      channel = Channel.where(name: 'Foursquare').first
      if channel.present?
        if params['checkin'].blank?
          render nothing: true
        else
          checkin = Oj.load(params['checkin'])
          user = User.where(provider_uid: checkin['user']['id']).first
          if ActionType.where(channel_id: channel.id).where(provider_uid: checkin['venue']['id']).present?
            action_type = ActionType.where(channel_id: channel.id).where(provider_uid: checkin['venue']['id']).first
          elsif ActionType.where(channel_id: channel.id).where(name: checkin['venue']['name']).present?
            action_type = ActionType.where(channel_id: channel.id).where(name: checkin['venue']['name']).first
          end
          if user.present? && action_type.present?
            # update the venue name if we have the venue_id
            if action_type.name.blank?
              action_type.update_attribute(:name, checkin['venue']['name'])
            end
            user.actions.create(
              action_type_id: action_type.id,
              api_key: channel.api_key,
              record_id: checkin['id'],
              case_id: checkin['id'],
              description: checkin['shout'],
              latitude: checkin['venue']['location']['lat'],
              longitude: checkin['venue']['location']['lng'],
              address: checkin['venue']['location']['address'],
              city: checkin['venue']['location']['city'],
              zipcode: checkin['venue']['location']['postalCode'],
              state: checkin['venue']['location']['state'],
              timestamp: Time.now
            )
            render nothing: true
          end
        end
      else
        logger.info "No Channel found"
        render nothing: true
      end
    else
      logger.info "Invalid FOURSQUARE_PUSH_SECRET"
      render nothing: true
    end
  end
  
  def citizens_connect
    channel = Channel.where(api_key: params['api_key']).first
    if channel.present?
      if params['user']['email'].present? || params['user']['contact_id'].present?
        if params['user']['email'].present?
          @user = User.where(email: params['user']['email']).first_or_initialize
        elsif params['user']['contact_id'].present?
          @user = User.where(contact_id: params['user']['contact_id']).first_or_initialize
        end

        # Create a User with a random password if @user doesn't yet exist
        create_devise_user(@user) unless @user.persisted?

        if params['report'].present?
          # Citizens Connect is allowed to create new action types on the fly ('first_or_create')
          action_type = ActionType.where(channel_id: channel.id).where(name: params['report']['service']).first_or_create
          action = @user.actions.create(
            action_type_id: action_type.id,
            api_key:        params['api_key'],
            record_id:      params['report']['record_id'],
            case_id:        params['report']['case_id'],
            event:          params['report']['event'],
            description:    params['report']['description'],
            shared:         params['report']['shared'],
            latitude:       params['report']['latitude'],
            longitude:      params['report']['longitude'],
            url:            params['report']['url'],
            image_url:      params['report']['image_url'],
            timestamp:      params['report']['timestamp']
          )
          @completed_campaigns = @user.campaigns_completed_by_action(action)
          NotificationMailer.status_email(@user, action).deliver
          respond_with(@completed_campaigns)
        else
          logger.info "********** No report params suplied **********"
        end
      else
        logger.info "********** No user params supplied **********"
        return "No user info supplied"
      end
    else
      logger.info "********** Invalid API_KEY **********"
      return "Invalid API_KEY"
    end
  end
  
  def street_bump
    channel = Channel.where(api_key: params['api_key']).first
    if channel.present?
      if params['user']['email'].present? || params['user']['contact_id'].present?
        logger.info "********** Creating user and action from params **********"
        if params['user']['email'].present?
          @user = User.where(email: params['user']['email']).first_or_initialize
        elsif params['user']['contact_id'].present?
          @user = User.where(contact_id: params['user']['contact_id']).first_or_initialize
        end

        # Create a User with a random password if @user doesn't yet exist
        create_devise_user(@user) unless @user.persisted?

        if params['trip'].present?
          action_type = ActionType.where(channel_id: channel.id).where(name: params['trip']['service']).first_or_create
          action = @user.actions.create(
            action_type_id: action_type.id,
            api_key: params['api_key'],
            record_id: params['trip']['trip_id'],
            event: params['trip']['event'],
            shared: params['trip']['shared'],
            latitude: params['trip']['latitude'],
            longitude: params['trip']['longitude'],
            started_at: params['trip']['started_at'],
            duration: params['trip']['duration'],
            bumps: params['trip']['bumps'],
            timestamp: params['trip']['timestamp']
          )
          @completed_campaigns = @user.campaigns_completed_by_action(action)
          NotificationMailer.status_email(@user, action).deliver
          respond_with(@completed_campaigns)
        else
          logger.info "********** No trip params suplied **********"
        end
      else
        logger.info "********** No user params supplied **********"
        return "No user info supplied"
      end
    else
      logger.info "********** Invalid API_KEY **********"
      return "Invalid API_KEY"
    end
  end
  
  protected

  def create_devise_user(user)
    password = Devise.friendly_token.first(8)
    user.password = password
    user.password_confirmation = password
    user.save!
  end

  # def verify_api_token
  #   if Channel.where(api_key: params['api_key']).present?
  # end
end
