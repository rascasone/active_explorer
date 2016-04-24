require 'spec_helper'

describe Mindmapper do
  GENERATED_DIRECTORY = 'spec/files/generated'

  before :all do
    FileUtils.rm_rf GENERATED_DIRECTORY
  end

  # after :each do
  #   FileUtils.rm_rf GENERATED_DIRECTORY
  # end

  let(:author) { create :author_of_books }

  describe 'its filters' do

    context 'when filter is empty' do
      it 'exports all objects' do
        file = target_file "all_objects.png"

        author.generate_mindmap file_path: file

        expect(File).to exist(file), "File #{file} doesn't exist."
      end
    end

    context 'when filter covers only some models' do
      it 'exports multilevel graph' do
        file = target_file "author_and_books.png"

        author.generate_mindmap file_path: file, associations_filter: [:books]

        expect(File).to exist(file), "File #{file} doesn't exist."
      end

      context 'and depth is set' do
        it 'exports multilevel graph' do
          file = target_file "author_books_reviews.png"

          author.generate_mindmap file_path: file, associations_filter: [:books, :reviews], max_depth: 2

          expect(File).to exist(file), "File #{file} doesn't exist."
        end
      end
    end

    context 'when filter covers all models' do
      it 'exports multilevel graph' do
        file = target_file "author_books_reviews_authors.png"

        author.generate_mindmap file_path: file, associations_filter: [:books, :reviews, :authors], max_depth: 10

        expect(File).to exist(file), "File #{file} doesn't exist."
      end
    end

  end

  def target_file(name)
    File.join GENERATED_DIRECTORY, name
  end
end