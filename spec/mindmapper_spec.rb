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

  describe 'its basic features' do
    it 'creates file' do
      file = target_file("mindmap_save_test.png")

      author.generate_mindmap file_path: file

      expect(File).to exist(file), "File #{file} doesn't exist."
    end
  end

  describe 'its filters' do

    context 'when filter is empty' do
      it 'exports all objects' do
        mindmap = author.generate_mindmap file_path: target_file("all_objects.png")

        expect(mindmap.graph.node_count).to eq(5)
        expect(mindmap.graph.edge_count).to eq(4)
      end
    end

    context 'when filter covers only some models' do
      it 'exports multilevel graph' do
        mindmap = author.generate_mindmap file_path: target_file("author_and_books.png"),
                                associations_filter: [:books]

        expect(mindmap.graph.node_count).to eq(3)
        expect(mindmap.graph.edge_count).to eq(2)
      end

      context 'and depth is set' do
        it 'exports multilevel graph' do
          mindmap = author.generate_mindmap file_path: target_file("author_books_reviews.png"),
                                  associations_filter: [:books, :reviews], max_depth: 3

          expect(mindmap.graph.node_count).to eq(4)
          expect(mindmap.graph.edge_count).to eq(3)
        end
      end
    end

    context 'when filter covers all models' do
      it 'exports multilevel graph' do
        mindmap = author.generate_mindmap file_path: target_file("author_books_reviews_authors.png"),
                                associations_filter: [:books, :reviews, :authors], max_depth: 10

        expect(mindmap.graph.node_count).to eq(5)
        expect(mindmap.graph.edge_count).to eq(4)
      end
    end

  end

  def target_file(name)
    File.join GENERATED_DIRECTORY, name
  end

end