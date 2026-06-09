require "test_helper"

class ReportGroupTest < ActiveSupport::TestCase
  test "name is required" do
    report_group = ReportGroup.new

    assert_not report_group.valid?
    assert report_group.errors[:name].any?
  end
end
