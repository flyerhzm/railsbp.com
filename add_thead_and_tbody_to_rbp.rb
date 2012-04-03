Dir["builds/**/rbp.html"].each do |filename|
  lines = File.readlines(filename)
  if lines[5] =~ /tr/
    lines.insert(1, "  <thead>\n")
    lines.insert(7, "  </thead>\n")
    lines.insert(8, "  <tbody>\n")
    lines.insert(-2, "  </tbody>\n")
  else
    lines.insert(1, "  <thead>\n")
    lines.insert(9, "  </thead>\n")
    lines.insert(10, "  <tbody>\n")
    lines.insert(-2, "  </tbody>\n")
  end
  File.open(filename, "w") do |file|
    file.write(lines.join(""))
  end
end
