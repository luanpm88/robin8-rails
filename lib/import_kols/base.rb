module  ImportKols
  class Base
    @@tags = nil
    def self.get_profession(name)
      return nil if name.nil?
      if @@tags.nil?
        @@tags = {}
        Tag.all.each do |p|
          @@tags[p.label] = p.id
        end
      end
      @@tags[name] ||  @@tags['综合']
    end

  end
end
