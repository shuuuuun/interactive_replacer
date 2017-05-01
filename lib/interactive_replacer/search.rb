module InteractiveReplacer
  class Search
    attr_reader :results

    def initialize
      @results = []
    end

    def find_all(path, search_text)
    end

    def find_directory(path, search_text)
    end

    def find_filename(path, search_text)
    end

    def find_in_file_recursive(path, search_text)
      target_file_paths(path).each do |file_path|
        find_in_file(file_path, search_text)
      end
    end

    def find_in_file(file_path, search_text)
      file_text = File.read(file_path)
      # 配列にしてeachだと遅そうな気がする。あとで確認してもいいかも。
      # file_lines = file_text.split("\n")
      # file_lines.each do |line|
      # end
      match_data_list = match_global(file_text, search_text)
      current_results = match_data_list.map do |match_data|
        {
          match_data: match_data,
          type: 'in_file', # in_file, directory, filename
          path: file_path, # 'path/to/file_or_directory'
          offset: match_data.begin(0), # x 全体の何文字目か
          line: match_line_num(file_text, match_data), # y, row 行数
          colmun: match_colmun_num(file_text, match_data), # x, colmun その行の何文字目か
        }
      end
      @results.concat current_results
    end

    private

    def target_file_paths(path)
      paths = Dir.glob "#{path}/**/*"
      paths.reject { |path| File.directory?(path) }
    end

    def target_directory_paths(path)
      paths = Dir.glob "#{path}/**/*"
      paths.select { |path| File.directory?(path) }
    end

    def match_line_num(text, match_data)
      offset = match_data.begin(0)
      text.slice(0..offset).count("\n") + 1
    end

    def match_colmun_num(text, match_data)
      offset = match_data.begin(0)
      text.slice(0..offset).split("\n").last.size
    end

    def match_global(str, regexp)
      match_data_list = []
      match_data = str.match(regexp)
      until match_data.nil?
        match_data_list << match_data
        offset = match_data.end(0)
        match_data = str.match(regexp, offset)
      end
      match_data_list
    end
  end
end
