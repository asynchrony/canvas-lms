require_relative '../../helpers/gradezilla_common'
require_relative '../page_objects/gradezilla_page'

describe "Gradezilla - custom columns" do
  include_context "in-process server selenium tests"
  include GradezillaCommon

  let(:gradezilla_page) { Gradezilla::MultipleGradingPeriods.new }

  before(:once) { gradebook_data_setup }
  before(:each) { user_session(@teacher) }

  def custom_column(opts = {})
    opts.reverse_merge! title: "<b>SIS ID</b>"
    @course.custom_gradebook_columns.create! opts
  end

  def header(n)
    f(".container_0 .slick-header-column:nth-child(#{n})")
  end

  it "shows custom columns", priority: "2", test_id: 164225 do
    hidden = custom_column title: "hidden", hidden: true
    col = custom_column
    col.update_order([col.id, hidden.id])

    col.custom_gradebook_column_data.new.tap do |d|
      d.user_id = @student_1.id
      d.content = "123456"
    end.save!

    gradezilla_page.visit(@course)

    expect(header(3)).to include_text col.title
    expect(ff(".container_0 .slick-header-column").map(&:text).join).not_to include hidden.title
    expect(ff(".slick-cell.custom_column").count { |c| c.text == "123456" }).to eq 1
  end

  it "lets you show and hide the teacher notes column", priority: "1", test_id: 164008 do
    gradezilla_page.visit(@course)

    has_notes_column = lambda do
      ff(".container_0 .slick-header-column").any? { |h| h.text == "Notes" }
    end
    expect(has_notes_column.call).to be_falsey

    dropdown_link = f("#gradebook_settings")
    click_dropdown_option = ->(option) do
      dropdown_link.click
      ff(".gradebook_dropdown a").find { |a| a.text == option }.click
      wait_for_ajaximations
    end
    show_notes = -> { click_dropdown_option.call("Show Notes Column") }
    hide_notes = -> { click_dropdown_option.call("Hide Notes Column") }

    # create the column
    show_notes.call
    expect(has_notes_column.call).to be_truthy

    # hide the column
    hide_notes.call
    expect(has_notes_column.call).to be_falsey

    # un-hide the column
    show_notes.call
    expect(has_notes_column.call).to be_truthy
  end
end
