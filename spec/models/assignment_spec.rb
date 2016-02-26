# == Schema Information
#
# Table name: assignments
#
#  id            :integer          not null, primary key
#  created_at    :datetime
#  updated_at    :datetime
#  user_id       :integer
#  course_id     :integer
#  article_id    :integer
#  article_title :string(255)
#  role          :integer
#  wiki_id       :integer
#

require 'rails_helper'

describe Assignment do
  describe 'assignment creation' do
    it 'should create Assignment objects' do
      assignment = build(:assignment)
      assignment2 = build(:redlink)

      expect(assignment.id).to be_kind_of(Integer)
      expect(assignment2.article_id).to be_nil
      expect(assignment.wiki_id).to eq(Wiki.default_wiki.id)
    end

    it 'should create assignment with database-form titles' do
      # TODO
    end
  end

  describe '#page_url' do
    it 'should generate url for any wiki' do
      # TODO
    end
  end
end
