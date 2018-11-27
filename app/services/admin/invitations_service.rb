class Admin::InvitationsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def invitations
    @invitations ||= resource_scope.order("#{sort_column} #{sort_direction}")
      .paginate(page: params[:page], per_page: 30)
  end

  private

  def resource_scope
    community.invitations.joins(:inviter).left_outer_joins(:community_memberships)
  end

  def sort_column
    case params[:sort]
    when 'send_by'
      'CONCAT(people.given_name, people.family_name)'
    when 'send_to'
      'invitations.email'
    when 'used'
      'invitations.usages_left'
    when 'started', nil
      'invitations.created_at'
    end
  end

  def sort_direction
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end
end