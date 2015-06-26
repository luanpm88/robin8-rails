class UpdateEmailPitchDraftLink < ActiveRecord::Migration
  def up
    DraftPitch.all.each do |p|
      if not URI.extract(p.email_pitch, /http(s)?/).blank?
        url = URI.extract(p.email_pitch, /http(s)?/)
        host = URI.parse(url[0]).host.split('.')[0]
        unless url[0].include? "utm_medium"
          encodedString = URI.escape("?utm_source=Robin8&amp;utm_medium=email&amp;utm_campaign=", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          value = p.email_pitch.gsub(url[0], "#{url[0]}#{encodedString}#{host}")
          p.update(:email_pitch => value)
          p.save
        end
      end
    end
  end
end
