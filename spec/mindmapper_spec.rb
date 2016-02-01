require 'spec_helper'

describe MindMapper do
  GENERATED_DIRECTORY = 'spec/files/generated'

  before :each do
    FileUtils.rm_rf GENERATED_DIRECTORY
  end

  after :each do
    FileUtils.rm_rf GENERATED_DIRECTORY
  end

  it 'should export Person class to PNG' do
    file_path = File.join GENERATED_DIRECTORY, "person.png"

    person = Person.new
    person.generate_mindmap file_path

    expect(File).to exist(file_path), "File #{file_path} doesn't exist."
  end

  it 'should '
end