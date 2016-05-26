require 'spec_helper'

describe ActiveExplorer do

  # TODO: In each test create desired hash and compare it with received exploration_hash.

  # TODO: Add test model with has_one association.

  GENERATED_DIRECTORY = 'spec/files/generated'

  # before :all do
  #   FileUtils.rm_rf GENERATED_DIRECTORY
  # end

  # after :each do
  #   FileUtils.rm_rf GENERATED_DIRECTORY
  # end

  let(:author) { create :author_of_books }

  it 'exports all objects' do
    exploration = author.explore association_filter: [:all]
    exploration.to_console

    exploration_hash = exploration.get_hash

    expect(exploration_hash.keys).to eq([:class_name, :attributes, :subobjects])
    expect(exploration_hash[:class_name]).to eq(author.class.name)
    expect(exploration_hash[:attributes][:id]).to eq(author.id)

    books = exploration_hash[:subobjects]
    expect(books.count).to eq(2)

    reviews = books.first[:subobjects]
    expect(reviews.count).to eq(1)

    review_authors = reviews.first[:subobjects]
    expect(review_authors.count).to eq(1)
  end

  it 'exports only direct predecessors and ancestors' do
    exploration = author.books.first.explore
    exploration.to_console

    exploration_hash = exploration.get_hash

    expect(exploration_hash[:subobjects].count).to eq(2)
    expect(exploration_hash[:subobjects].first[:subobjects]).to be_empty
    expect(exploration_hash[:subobjects].second[:subobjects]).to be_empty
  end

  describe 'filters' do

    describe 'class filter' do
      context 'when filter covers only some models' do
        it 'show only books' do
          exploration_hash = author.explore(class_filter: [:books]).get_hash
          books = exploration_hash[:subobjects]

          author.books.count.times do |i|
            expect(books[i][:subobjects]).to be_empty
          end
        end

        it 'show only books (alternative notation)' do
          exploration_hash = author.explore(class_filter: { show: [:books] }).get_hash
          books = exploration_hash[:subobjects]

          author.books.count.times do |i|
            expect(books[i][:subobjects]).to be_empty
          end
        end

        context 'and depth is set' do
          it 'shows books and reviews' do
            exploration_hash = author.explore(class_filter: [:books, :reviews], depth: 3).get_hash

            books = exploration_hash[:subobjects]
            reviews = books.first[:subobjects]

            expect(reviews.first[:subobjects]).to be_empty
          end
        end
      end

      context 'when filter covers all models' do
        it 'exports multilevel graph' do
          exploration_hash = author.explore(class_filter: [:books, :reviews, :authors], depth: 10).get_hash

          books = exploration_hash[:subobjects]
          reviews = books.first[:subobjects]

          expect(reviews.first).to have_key(:subobjects)
        end
      end
    end

    describe 'association filter' do
      it 'show only review' do
        exploration = author.books.first.explore(association_filter: [:has_many])
        exploration.to_console

        exploration_hash = exploration.get_hash

        expect(exploration_hash[:subobjects]).not_to be_nil
        expect(exploration_hash[:subobjects].count).to eq(1)
        expect(exploration_hash[:subobjects].first[:class_name]).to eq('Review')
        expect(exploration_hash[:subobjects].first[:subobjects]).to be_empty
      end

      it 'show only author' do
        exploration = author.books.first.explore(association_filter: [:belongs_to])
        exploration.to_console

        exploration_hash = exploration.get_hash

        expect(exploration_hash[:subobjects]).not_to be_nil
        expect(exploration_hash[:subobjects].count).to eq(1)
        expect(exploration_hash[:subobjects].first[:class_name]).to eq('Author')
        expect(exploration_hash[:subobjects].first[:subobjects]).to be_empty
      end
    end

  end

  describe 'error handling' do

    context 'when association is incorrectly defined' do
      let(:bad_guy) { create(:bad_guy) }
      let(:file_name) { 'bad_guy.png' }

      it 'should catch error inside' do
        expect { bad_guy.explore.get_hash }.not_to raise_error
      end

      it 'write message to mindmap' do
        exploration_hash = bad_guy.explore.get_hash

        expect(exploration_hash).to have_key(:error_message)
      end
    end

  end

  describe 'output to console' do

    it 'outputs first line' do
      exploration_hash = author.explore
      hash = author.explore.get_hash

      output = capture_output { exploration_hash.to_console }

      expect(output).to include("Author(#{hash[:attributes][:id]})")
    end

    it 'outputs multiline' do
      exploration_hash = author.explore
      hash = author.explore.get_hash[:subobjects].first

      output = capture_output { exploration_hash.to_console }

      expect(output).to include("  -> has Book(#{hash[:attributes][:id]})")
    end

    it 'outputs error' do
      bad_guy = create(:bad_guy)

      output = capture_output { bad_guy.explore.to_console }

      expect(output).to include("Error in BadGuy")
    end

  end

  describe 'output to image' do
    describe 'its basic features' do
      it 'creates file' do
        file = target_file("mindmap_save_test.png")

        author.explore(association_filter: [:all]).to_image file

        expect(File).to exist(file), "File #{file} doesn't exist."
      end

      it 'works with unsafe strings' do
        file = target_file("unsafe_string.png")

        author.books.create title: 'Nebezpečná kniha s češtinou', year: 666
        author.books.create title: 'Filter these: {}<>', year: 1666
        author.books.create title: 'These are ok: /*&^%$@#!():;.|+-=`[]*/', year: 2016

        author.explore.to_image file

        expect(File).to exist(file), "File #{file} doesn't exist."
      end
    end

    describe 'its filters' do

      context 'when filter is empty' do
        it 'exports all objects' do
          graph = author.explore(association_filter: [:all]).to_image target_file("all_objects.png")

          expect(graph.node_count).to eq(5)
          expect(graph.edge_count).to eq(4)
        end
      end

      context 'when filter covers only some models' do
        it 'exports multilevel graph' do
          graph = author.explore(class_filter: [:books], association_filter: [:all]).to_image target_file("author_and_books.png")

          expect(graph.node_count).to eq(3)
          expect(graph.edge_count).to eq(2)
        end

        context 'and depth is set' do
          it 'exports multilevel graph' do
            graph = author.explore(class_filter: [:books, :reviews], association_filter: [:all], depth: 3).to_image target_file("author_books_reviews.png")

            expect(graph.node_count).to eq(4)
            expect(graph.edge_count).to eq(3)
          end
        end
      end

      context 'when filter covers all models' do
        it 'exports multilevel graph' do
          graph = author.explore(class_filter: [:books, :reviews, :authors], association_filter: [:all], depth: 10).to_image target_file("author_books_reviews_authors.png")

          expect(graph.node_count).to eq(5)
          expect(graph.edge_count).to eq(4)
        end
      end

    end

    describe 'its options' do
      it 'exports centralized style' do
        graph = author.books.first.explore(association_filter: [:all]).to_image(target_file("origin_as_root_on.png"), origin_as_root: true)

        expect(graph.node_count).to eq(5)
        expect(graph.edge_count).to eq(4)
      end

      it 'exports non-centralized style' do
        graph = author.books.first.explore(association_filter: [:all]).to_image(target_file("origin_as_root_off.png"), origin_as_root: false)

        expect(graph.node_count).to eq(5)
        expect(graph.edge_count).to eq(4)
      end
    end

  end

  def target_file(name)
    File.join GENERATED_DIRECTORY, name
  end

  def capture_output
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

end