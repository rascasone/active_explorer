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
    exploration_hash = exploration.get_hash

    expect(exploration_hash[:subobjects].count).to eq(2)
    expect(exploration_hash[:subobjects].first).not_to have_key(:subobjects)
    expect(exploration_hash[:subobjects].second).not_to have_key(:subobjects)
  end

  describe 'object parameters' do
    it 'has class_name' do
      exploration_hash = author.explore(association_filter: [:all]).get_hash

      expect(exploration_hash).to have_key(:class_name)
    end

    it 'has attributes' do
      exploration_hash = author.explore(association_filter: [:all]).get_hash

      expect(exploration_hash).to have_key(:attributes)
    end

    it 'has subobjects' do
      exploration_hash = author.explore(association_filter: [:all]).get_hash

      expect(exploration_hash).to have_key(:subobjects)
    end
  end

  describe 'filters' do

    describe 'class filter' do

      context 'as array' do

        context 'when it specifies books' do
          let(:books) { author.explore(class_filter: [:books]).get_hash[:subobjects] }

          it 'shows only books' do
            expect(books).not_to be_empty

            author.books.count.times do |i|
              expect(books[i]).not_to have_key(:subobjects)
            end
          end

          it 'does not show review' do
            books.each do |book|
              expect(book).not_to have_key(:subobjects)
            end
          end
        end

        context 'when limiting depth is set' do
          let(:books) { author.explore(class_filter: [:books, :reviews], depth: 1).get_hash[:subobjects] }
          # let(:review) { books.first[:subobjects].first }

          it 'shows only books' do
            expect(books).not_to be_empty
          end

          it 'ignores review' do
            books.each do |book|
              expect(book[:subobjects]).to be_nil
            end
          end
        end

        context 'when filter and depth covers all models' do
          let(:books) { author.explore(class_filter: [:books, :reviews, :authors], association_filter: [:all], depth: 10).get_hash[:subobjects] }
          let(:review) { books.first[:subobjects].first }
          let(:author_of_review) { review[:subobjects].first }

          it 'show all objects' do
            expect(books).not_to be_empty
            expect(review).not_to be_nil
            expect(author_of_review).not_to be_nil
          end
        end

      end

      context 'as hash' do

        context 'when it specifies to show only books' do
          let(:books) { author.explore(class_filter: { show: [:books] }).get_hash[:subobjects] }

          it 'shows books' do
            expect(books).not_to be_empty
          end

          it 'ignores reviews' do
            author.books.count.times do |i|
              expect(books[i]).not_to have_key(:subobjects)
            end
          end
        end

      end

    end

    describe 'association filter' do

      context 'when has_many' do
        let(:book) { author.books.first.explore(association_filter: [:has_many]).get_hash }

        it 'shows review' do
          expect(book[:subobjects]).not_to be_nil
          expect(book[:subobjects].count).to eq(1)
          expect(book[:subobjects].first[:class_name]).to eq('Review')
          expect(book[:subobjects].first).not_to have_key(:subobjects)
        end

        it 'ignores author of review' do
          review = book[:subobjects].first
          expect(review).not_to have_key(:subobjects)
        end
      end

      context 'when belongs_to' do
        let(:book) { author.books.first.explore(association_filter: [:belongs_to]).get_hash }

        it 'shows author' do
          expect(book[:subobjects]).not_to be_nil
          expect(book[:subobjects].count).to eq(1)
          expect(book[:subobjects].first[:class_name]).to eq('Author')
        end

        it 'ignores author\'s subobjets' do
          author = book[:subobjects].first
          expect(author).not_to have_key(:subobjects)
        end
      end

      context 'when all' do
        let(:book) { author.books.first.explore(association_filter: [:all]).get_hash }
        let(:author_of_book) { book[:subobjects].first }
        let(:review) { book[:subobjects].second }
        let(:author_of_review) { review[:subobjects].first }

        it 'show all objects' do
          expect(book).not_to be_empty
          expect(author_of_book).not_to be_nil
          expect(review).not_to be_nil
          expect(author_of_review).not_to be_nil
        end
      end

    end

    describe 'attributes filter' do
      let(:book) { author.books.first.explore(attribute_filter: { books: [:id, :title] }).get_hash }

      it 'shows only id and name of book' do
        expect(book[:attributes].keys).to eq([:id, :title])
      end
    end

  end

  describe 'global configuration' do
    it 'can configure all filters' do
      expect(ActiveExplorer::Config).to respond_to(:class_filter, :class_filter=)
      expect(ActiveExplorer::Config).to respond_to(:attribute_filter, :attribute_filter=)
      expect(ActiveExplorer::Config).to respond_to(:association_filter, :association_filter=)
    end

    describe 'class filter' do
      context 'when books are filtered' do
        before :all do
          ActiveExplorer::Config.class_filter = [:books]
        end

        after :all do
          ActiveExplorer::Config.class_filter = nil
        end

        let(:books) { author.explore.get_hash[:subobjects] }

        it 'allows only books' do
          expect(books).not_to be_empty

          author.books.count.times do |i|
            expect(books[i]).not_to have_key(:subobjects)
          end
        end

        it 'forbids review' do
          books.each do |book|
            expect(book).not_to have_key(:subobjects)
          end
        end
      end
    end

    describe 'attribute filter' do
      context 'when book and review attributes are filtered' do
        before :all do
          ActiveExplorer::Config.attribute_filter = { books: [:id, :title], reviews: [:id] }
        end

        after :all do
          ActiveExplorer::Config.attribute_filter = nil
        end

        let(:books) { author.explore.get_hash[:subobjects] }
        let(:review) { books.first[:subobjects].first }

        it 'allows id and title for books' do
          author.books.count.times do |i|
            expect(books[i][:attributes]).to have_key(:id)
            expect(books[i][:attributes]).to have_key(:title)
          end
        end

        it 'forbids year for book' do
          author.books.count.times do |i|
            expect(books[i][:attributes]).not_to have_key(:year)
          end
        end

        it 'allows id for review' do
          expect(review[:attributes]).to have_key(:id)
        end

        it 'forbids stars and text for review' do
          expect(review[:attributes]).not_to have_key(:stars)
          expect(review[:attributes]).not_to have_key(:text)
        end
      end
    end

    describe 'association filter' do
      before :all do
        ActiveExplorer::Config.association_filter = [:has_many]
      end

      after :all do
        ActiveExplorer::Config.association_filter = nil
      end

      context 'when has_many is forced' do
        let(:book) { author.books.first.explore.get_hash }

        it 'allows review' do
          expect(book).to have_key(:subobjects)
          expect(book[:subobjects].count).to eq(1)
          expect(book[:subobjects].first[:class_name]).to eq('Review')
        end

        it 'forbids author of book' do
          expect(book[:subobjects].count).to eq(1)
          expect(book[:subobjects].first[:class_name]).not_to eq('Author')
        end

        it 'forbids author of review' do
          review = book[:subobjects].first
          expect(review).not_to have_key(:subobjects)
        end
      end

      context 'when belongs_to' do
        let(:book) { author.books.first.explore(association_filter: [:belongs_to]).get_hash }

        it 'shows author' do
          expect(book[:subobjects]).not_to be_nil
          expect(book[:subobjects].count).to eq(1)
          expect(book[:subobjects].first[:class_name]).to eq('Author')
        end

        it 'ignores author\'s subobjets' do
          author = book[:subobjects].first
          expect(author).not_to have_key(:subobjects)
        end
      end

      context 'when all' do
        let(:book) { author.books.first.explore(association_filter: [:all]).get_hash }
        let(:author_of_book) { book[:subobjects].first }
        let(:review) { book[:subobjects].second }
        let(:author_of_review) { review[:subobjects].first }

        it 'show all objects' do
          expect(book).not_to be_empty
          expect(author_of_book).not_to be_nil
          expect(review).not_to be_nil
          expect(author_of_review).not_to be_nil
        end
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