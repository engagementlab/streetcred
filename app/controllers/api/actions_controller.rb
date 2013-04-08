class Api::ActionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # before_filter :verify_api_token
  
  respond_to :json
  
  # generic create
  def create
    if params['email'].present?
      user = User.where(email: params['email']).first_or_create
      action = user.actions.create(params['action'])
      @earned_awards = user.awards_earned_by_action(action)
      NotificationMailer.status_email(user, action).deliver
      respond_with(@earned_awards)
    end
  end
  
  def foursquare
    if params['secret'] == ENV['FOURSQUARE_PUSH_SECRET'] # 'BOL410IIRYOQ1FEAYT1PZYGYDVN5OYUYI1JO5CI2SW3UNO20'
      if params['checkin'].blank?
        render :nothing => true
      else
        checkin = Oj.load(params['checkin'])
        user = User.where(provider_uid: checkin['user']['id']).first
        if ActionType.where(provider_uid: checkin['venue']['id']).present?
          action_type = ActionType.where(provider_uid: checkin['venue']['id']).first
        elsif ActionType.where(name: "Foursquare Checkin: #{checkin['venue']['name']}").present?
          action_type = ActionType.where(name: "Foursquare Checkin: #{checkin['venue']['name']}").first
        end
        if user.present? && action_type.present?
          if action_type.name.blank?
            action_type.update_attribute(:name, "Foursquare Checkin: #{checkin['venue']['name']}")
          end
          user.actions.create(
            api_key: Channel.where(name: 'Foursquare').first.try(:api_key),
            record_id: checkin['id'],
            case_id: checkin['id'],
            action_type: action_type.name,
            description: checkin['shout'],
            latitude: checkin['venue']['location']['lat'],
            longitude: checkin['venue']['location']['lng'],
            address: checkin['venue']['location']['address'],
            city: checkin['venue']['location']['city'],
            zipcode: checkin['venue']['location']['postalCode'],
            state: checkin['venue']['location']['state'],
            timestamp: Time.now
          )
        end
        render :nothing => true
      end
    else
      logger.info "Invalid FOURSQUARE_PUSH_SECRET"
      render :nothing => true
    end
  end
  
  def citizens_connect
    if Channel.where(api_key: params['api_key']).present?
      if params['user']['email'].present? || params['user']['contact_id'].present?
        if params['user']['email'].present?
          user = User.where(email: params['user']['email']).first_or_create
        elsif params['user']['contact_id'].present?
          user = User.where(contact_id: params['user']['contact_id']).first_or_create
        end
        user.update_attributes(params['user'])
        action_type = ActionType.where(name: params['report']['service']).first_or_create
        action = user.actions.create(
          api_key: params['api_key'],
          record_id: params['report']['record_id'],
          case_id: params['report']['case_id'],
          event: params['report']['event'],
          action_type: action_type.name,
          description: params['report']['description'],
          shared: params['report']['shared'],
          latitude: params['report']['latitude'],
          longitude: params['report']['longitude'],
          url: params['report']['url'],
          image_url: params['report']['image_url'],
          timestamp: params['report']['timestamp']
        )
        @earned_awards = user.awards_earned_by_action(action)
        NotificationMailer.status_email(user, action).deliver
        respond_with(@earned_awards)
      else
        return "No user info supplied"
      end
    else
      return "Invalid API_KEY"
    end
  end
  
  private
  def verify_api_token
    # if Channel.where(api_key: params['api_key']).present?
  end
end
