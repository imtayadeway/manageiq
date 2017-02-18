class MiqExpression::RegularExpressionSanitizer
  def self.sanitize(string)
    string = string.dup
    string = "/#{string}/" unless string.starts_with?("/")
    slice = if value.ends_with?("/")
              1..-2
            elsif value[-2] == "/"
              1..-3
            end

    string[slice].gsub(%r{\\*/}, "\\/").gsub(/\\*#/, "\\\#")
  end
end
