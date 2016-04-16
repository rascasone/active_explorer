require 'spec_helper'

describe Mindmapper do
  GENERATED_DIRECTORY = 'spec/files/generated'

  before :each do
    FileUtils.rm_rf GENERATED_DIRECTORY
  end

  after :each do
    # FileUtils.rm_rf GENERATED_DIRECTORY
  end

  let(:author) { create :author }

  it 'exports simple graph' do
    file_path = File.join GENERATED_DIRECTORY, "author_simple.png"

    author.generate_mindmap file_path: file_path

    expect(File).to exist(file_path), "File #{file_path} doesn't exist."
  end

  it 'exports multilevel graph' do
    file_path = File.join GENERATED_DIRECTORY, "author_and_books.png"

    author.generate_mindmap file_path: file_path, associations_filter: [:books]

    expect(File).to exist(file_path), "File #{file_path} doesn't exist."
  end
end