require "test_helper"

class ReportGroupsControllerTest < ActionDispatch::IntegrationTest
  test "index lists report groups" do
    get report_groups_url

    assert_response :success
    assert_select "td", text: report_groups(:goma_wood).name
  end

  test "updates report group" do
    report_group = report_groups(:goma_wood)

    patch report_group_url(report_group), params: {
      report_group: { name: "更新後", code: "A01" }
    }

    assert_redirected_to report_groups_url
    assert_equal "更新後", report_group.reload.name
    assert_equal "A01", report_group.code
  end
end
