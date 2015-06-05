class StreamPdf < Prawn::Document
  def initialize(stories)
    super()
    @stories = stories
    @stories.each do |story|
      render_story(story)
    end
    text "Text goes here"
  end
  
  def render_story(story)
    text story["title"]
  end
end
