# == Schema Information
#
# Table name: forums
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :text
#  topics_count       :integer          default(0), not null
#  last_post_date     :datetime
#  last_post_id       :integer
#  private            :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  allow_topic_voting :boolean          default(FALSE)
#  allow_post_voting  :boolean          default(FALSE)
#  layout             :string           default("table")
#

require 'test_helper'

class ForumTest < ActiveSupport::TestCase

  should have_many(:topics)
  should have_many(:posts)

  should validate_presence_of(:name)
  should validate_presence_of(:description)

  test "should count number of posts" do
    assert Forum.find(1).total_posts == 3
  end

  test "to_param" do
    assert Forum.find(1).to_param == "1-Private-Tickets"
  end


end
