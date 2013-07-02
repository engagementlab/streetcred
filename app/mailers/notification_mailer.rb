class NotificationMailer < ActionMailer::Base
  default from: "notifications@streetcred.us"
  add_template_helper(ApplicationHelper)
  
  def status_email(user, action)
    @user = user
    @action = action
    @completed_campaigns = user.campaigns_completed_by_action(action)
    @in_progress_campaigns = user.campaigns_in_progress_by_action(action)
    mail(:to => user.email,
         :subject => "Nice Work!")
  end
end
