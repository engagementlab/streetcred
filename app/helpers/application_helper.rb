module ApplicationHelper
  def progress_toward_award_helper(user, award, action)
    "#{user.matching_actions(award).count} out of #{award.required_occurrences_by_action(action)}"
  end
end
