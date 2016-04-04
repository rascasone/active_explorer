require 'spec_helper'

describe Mindmapper do
  GENERATED_DIRECTORY = 'spec/files/generated'

  before :each do
    FileUtils.rm_rf GENERATED_DIRECTORY
  end

  after :each do
    # FileUtils.rm_rf GENERATED_DIRECTORY
  end

  let(:person) { Person.create first_name: "Marek", last_name: "Ulicny" }

  it 'exports simple graph' do
    file_path = File.join GENERATED_DIRECTORY, "person_simple.png"

    person.generate_mindmap file_path: file_path

    expect(File).to exist(file_path), "File #{file_path} doesn't exist."
  end

  it 'exports multilevel graph' do
    file_path = File.join GENERATED_DIRECTORY, "person_and_books.png"

    person.books.create title: 'The Warded Man', year: 2008
    person.books.create title: 'The Desert Spear', year: 2010

    person.generate_mindmap file_path: file_path, associations: :books

    expect(File).to exist(file_path), "File #{file_path} doesn't exist."
  end
end