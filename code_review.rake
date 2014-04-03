require 'cgi'
require 'fileutils'
 
desc 'Generate a code review.'
# Uses rake code_review[master,qa] by default
task :code_review, :left_branch, :right_branch do |cmd, args|
  left_branch = ( args[:left_branch] || "master" )
  right_branch = ( args[:right_branch] || "qa" )
  gp = GitParser.new(left_branch, right_branch)
  gp.fancy_full_diff
end
 
class GitParser
 
  def initialize(left_branch = "master", right_branch = "qa")
    @left_branch       = left_branch
    @right_branch      = right_branch
  end
 
  def fancy_full_diff
    nav_html = ""
    FileUtils.mkdir_p("code_review")
    file_names = file_names_only
    file_names.each do |file|
      nav_html += "<a href='#{file_name_to_html(file)}'>#{file}</a><br />"
      diff_text = git_diff_file(file)
      file_hashes = parse_diff(diff_text, file)
      create_html(file, file_hashes[:left_branch], file_hashes[:right_branch])
    end
    html_buff = <<-HTML
                     <!DOCTYPE html>
                     <html>
                     <head>
                     <title>Code Review Directory</title>
                     <body>
                     #{nav_html}
                     </body>
                     </html>
                   HTML
    File.open("code_review/code_review_directory.html", "w") { |file| file.write(html_buff) }
  end
  
  def file_name_to_html(file_path)
    "#{File.dirname(file_path)}#{File.basename(file_path, File.extname(file_path))}.html"
  end
 
  def make_html_rows(diff_text)
    html = ""
    diff_text.each_index do |text_idx|
      text = diff_text[text_idx]
      color_text = case text[0,1]
                     when "-" then :minus
                     when "+" then :plus
                     else 
                      :no_color
                   end
      html += "<tr class='#{text_idx % 2 == 0 ? "even" : "odd"}'><td>#{text_idx + 1}</td><td><pre><span class='#{color_text.to_s}'>#{CGI::escapeHTML(text)}</span></pre></td></tr>"
    end
    html
  end   
 
  def create_html(file_path, left_file_rows, right_file_rows)
    html_buff = <<-HTML
                     <!DOCTYPE html>
                     <html>
                     <head>
                     <title>#{file_path}</title>
                     <style type="text/css">
                     
                     body          { font-family:      Helvetica,Arial,Verdana,sans-serif;
                                     font-size:        18px;
                                   }
                     th            { background-color: #D4C7BA;
                                     color:            #c00; 
                                   }
                     div           { margin:           20px;
                                     padding:          20px;
                                     border:           2px solid black;
                                     height:           650px;
                                     width:            600px;
                                     overflow:         scroll;
                                     white-space:      nowrap;
                                   }
                     .code_holder  { background-color: #CFCAC4;
                                     position:         absolute;
                                     left:             20px;
                                     top:              150px;
                                     margin:           0 auto;
                                     border-radius:    10px;
                                     box-shadow:       3px 3px 5px 6px #ccc;
                                   }
                     .odd td       { background-color: #F4EEE7;}
                     .even td      { background-color: #EEE3D6;}
                     .minus        { color:            red; }
                     .plus         { color:            green;}
                     </style>
                     <script type="text/javascript">
                       function setupHandlers(){
                         var leftBox = document.getElementById("left_diff_box");
                         var rightBox = document.getElementById("right_diff_box");
 
                         leftBox.onscroll = function(e) {
                            rightBox.scrollTop = leftBox.scrollTop;
                            rightBox.scrollLeft = leftBox.scrollLeft;
                         };
                         rightBox.onscroll = function(e) {
                            leftBox.scrollTop = rightBox.scrollTop;
                            leftBox.scrollLeft = rightBox.scrollLeft;
                         };
                       }
                     </script>
                     </head>
                     <body onload="setupHandlers()">
                     <table class="code_holder">
                      <tr>
                        <th>#{@left_branch}:#{file_path}</th>
                        <th>#{@right_branch}:#{file_path}</th>
                      </tr>
                      <tr valign="top">
                        <td>
                          <div id="left_diff_box">
                            <table>
                                #{make_html_rows(left_file_rows) if left_file_rows}
                            </table>
                          </div>
                        </td>
                        <td>
                          <div id="right_diff_box">
                            <table>
                              #{make_html_rows(right_file_rows)  if right_file_rows}
                            </table>
                          </div>
                        </td>
                      </tr>
                     </table>
                     </body>
                     </html>
                   HTML
    FileUtils.mkdir_p("code_review/" + File.dirname(file_path))
    File.open("code_review/#{file_name_to_html(file_path)}", "w") { |file| file.write(html_buff) }
  end
    
  def git_diff_branches
    IO.popen("git diff #{@left_branch} #{@right_branch} | cat ").readlines.collect(&:chomp)
  end
  
  def file_names_only
    IO.popen("git diff #{@left_branch} #{@right_branch} --name-only").readlines.collect(&:chomp)
  end
 
  def git_diff_file(file_path)
    IO.popen("git diff #{@left_branch}:#{file_path} #{@right_branch}:#{file_path} | cat ").readlines
  end
 
  def git_show_file(branch, file_path)
    IO.popen("git show #{branch}:#{file_path} | cat ").readlines
  end
 
  def remove_plus(array_of_lines)
    array_of_lines.select { |l|  l[0,1] != "+" }
  end
 
  def remove_minus(array_of_lines)
    array_of_lines.select { |l|  l[0,1] != "-" }
  end
 
  # pluses are from the right branch
  # minuses are what is present in the left branch
  def parse_diff(diff_text, file_path)
    file_left, file_right = git_show_file(@left_branch, file_path), git_show_file(@right_branch, file_path)
    starting_change_block = nil
    changed_lines = {}
    # gather starting points for changes and the block of text which is the change
    diff_text.each do |text|
      # text = diff_text[line_idx]
      found_line_stat = text[/\@\@\ \S+\ \S+\ \@\@/]
      if found_line_stat
        plus_line_start, minus_line_start = (found_line_stat[/\+\d+/][1..-1].to_i + 2), (found_line_stat[/\-\d+/][1..-1].to_i + 2)
        starting_change_block = "#{plus_line_start}_#{minus_line_start}"
        changed_lines[starting_change_block] = []
      elsif starting_change_block
        changed_lines[starting_change_block] << text
      end
    end
    changed_lines.each do |line_idx_key, line_val|
      line_indexes = line_idx_key.split("_")
        left_idx_int = line_indexes[0].to_i
        right_idx_int = line_indexes[1].to_i
        file_left[left_idx_int..line_val.size] = remove_plus(line_val)
        file_right[right_idx_int..line_val.size] = remove_minus(line_val)
    end
    {:left_branch => file_left.compact, :right_branch => file_right.compact}
  end
 
end