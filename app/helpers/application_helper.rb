module ApplicationHelper
  def progress_toward_award_helper(user, award)
    "#{user.matching_actions(award).count} out of #{award.required_occurrences}"
  end
end
