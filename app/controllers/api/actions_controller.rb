class Api::ActionsController < ApplicationController
  require 'mail'
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  # generic create
  def create
    if params['email'].present?
      user = User.where(email: params['email']).first_or_create
      action = user.actions.create(params['action'])
      @completed_campaigns = user.campaigns_completed_by_action(action)
      NotificationMailer.status_email(user, action).deliver
      respond_with(@completed_campaigns)
    end
  end

  # incoming email sent to 'reports@streetcred.us' and routed through CloudMailIn (Heroku Add-On)
  def email
    verify_email_signature
    message = Mail.new(params)

    if message.present?
      @user = User.where(email: message.from.first).first_or_initialize
      unless @user.persisted?
        password = Devise.friendly_token.first(8)
        @user.password = password
        @user.password_confirmation = password
        @user.save!
      end
      channel = Channel.where(name: 'Email').first
      action_type = ActionType.where(channel_id: channel.id).where(provider_uid: message.subject.try(:strip)).first
      if channel.present? && action_type.present?
        action = @user.actions.create(
          api_key: channel.api_key,
          action_type_id: action_type.id, 
          timestamp: message.date
        )
        @completed_campaigns = @user.campaigns_completed_by_action(action)
        @in_progress_campaigns = @user.campaigns_in_progress_by_action(action)
        if @in_progress_campaigns.present? || @completed_campaigns.present?
          NotificationMailer.status_email(@user, action).deliver
        end
        respond_with(@completed_campaigns)
      else
        logger.info "********** No matching ActionType found **********"
        return false
      end
    else
      logger.info "********** No from address **********"
      return false
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
              api_key: channel.api_key,
              record_id: checkin['id'],
              case_id: checkin['id'],
              action_type_id: action_type.id,
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
        unless @user.persisted?
          password = Devise.friendly_token.first(8)
          @user.password = password
          @user.password_confirmation = password
          @user.save!
        end
        if params['report'].present?
          # Citizens Connect is allowed to create new action types on the fly ('first_or_create')
          action_type = ActionType.where(channel_id: channel.id).where(name: params['report']['service']).first_or_create
          action = @user.actions.create(
            api_key:        params['api_key'],
            record_id:      params['report']['record_id'],
            case_id:        params['report']['case_id'],
            event:          params['report']['event'],
            action_type_id: action_type.id,
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
        unless @user.persisted?
          password = Devise.friendly_token.first(8)
          @user.password = password
          @user.password_confirmation = password
          @user.save!
        end
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

  def verify_email_signature
    provided = request.request_parameters.delete(:signature)
    signature = Digest::MD5.hexdigest(flatten_params(request.request_parameters).sort.map{|k,v| v}.join + ENV['CLOUDMAILIN_SECRET'])
    
    if provided != signature
      render :text => "Message signature fail #{provided} != #{signature}", :status => 403, :content_type => Mime::TEXT.to_s
      return false
    end
  end
  
  def flatten_params(params, title = nil, result = {})
    params.each do |key, value|
      if value.kind_of?(Hash)
        key_name = title ? "#{title}[#{key}]" : key
        flatten_params(value, key_name, result)
      else
        key_name = title ? "#{title}[#{key}]" : key
        result[key_name] = value
      end
    end
  
    return result
  end

  # def verify_api_token
  #   if Channel.where(api_key: params['api_key']).present?
  # end
end
