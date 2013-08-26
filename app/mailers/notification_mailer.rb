class NotificationMailer < ActionMailer::Base
  default from: "notifications@streetcred.us"
  add_template_helper(ApplicationHelper)
  
  def status_email(user, action, new_user)
    @user = user
    @action = action
    @new_user = new_user
    @completed_campaigns = user.campaigns_completed_by_action(action)
    @in_progress_campaigns = user.campaigns_in_progress_by_action(action)
    mail(:to => user.email,
         :subject => "Nice Work!")
  end
end
