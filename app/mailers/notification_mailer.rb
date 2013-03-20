class NotificationMailer < ActionMailer::Base
  default from: "notifications@streetcred.us"
  add_template_helper(ApplicationHelper)
  
  def status_email(user, action)
    @user = user
    @action = action
    @earned_awards = user.awards_earned_by_action(action)
    @in_progress_awards = user.awards_in_progress_by_action(action)
    mail(:to => user.email,
         :subject => "Nice Work!")
  end
end
