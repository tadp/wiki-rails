class Page < ActiveRecord::Base
  attr_accessible :name, :title, :content
  after_create :create_page
  after_update :update_page
  has_many :edits, class_name: "Page", foreign_key: "document_id"
  belongs_to :document, class_name: "Page"
  validates_uniqueness_of :name, if: :original_document?, on: :create

	def create_page
    begin
      commit = {
        :message => id.to_s,
        :name => 'Some Name',
        :email => 'some@example.com'
      }
      wiki.write_page(name, :markdown, content, commit)
      rescue => e
        # binding.pry
        logger.warn "#{e}"
    end
	end

  def update_page
    commit = { :message => 'commit message',
       :name => 'Tom Preston-Werner',
       :email => 'tom@github.com' }

    page = wiki.page(name)
    wiki.update_page(page, page.name, page.format, content, commit)
  end

  def show_content
    self_wiki.formatted_data
  end

  def archive
    self.display = false
    self.save
  end

  def self_wiki
    wiki.page(self.name)
    binding.pry
  end

  def wiki
    GollumRepo::Wiki
  end

  def all
    wiki.pages.reverse
  end

  def original_document?
    !document
  end
end
