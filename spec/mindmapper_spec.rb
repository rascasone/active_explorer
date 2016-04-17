require 'spec_helper'

describe Mindmapper do
  GENERATED_DIRECTORY = 'spec/files/generated'

  before :each do
    FileUtils.rm_rf GENERATED_DIRECTORY
  end

  after :each do
    # FileUtils.rm_rf GENERATED_DIRECTORY
  end

  let(:author) { create :author_of_books }

  it 'exports simple graph' do
    file = target_file "author_simple.png"

    author.generate_mindmap file_path: file

    expect(File).to exist(file), "File #{file} doesn't exist."
  end

  it 'exports multilevel graph' do
    file = target_file "author_and_books.png"

    author.generate_mindmap file_path: file, associations_filter: [:books]

    expect(File).to exist(file), "File #{file} doesn't exist."
  end

  it 'exports multilevel graph with set limit' do
    file = target_file "author_books_reviews.png"

    author.generate_mindmap file_path: file, associations_filter: [:books, :reviews], max_depth: 2

    expect(File).to exist(file), "File #{file} doesn't exist."
  end

  def target_file(name)
    File.join GENERATED_DIRECTORY, name
  end
end