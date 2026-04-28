# frozen_string_literal: true

# index.html 内の `const FALLBACK_CONFIG = { ... };` を括弧対応で取り出す（コメントアンカーに依存しない）
module RubyfightTest
  module FallbackHtmlExtract
    module_function

    # @return [String] 外側の `{` `}` を除いたオブジェクト本文
    # @raise [RuntimeError] マーカー欠如・括弧不整合
    def interior_config_object(html)
      marker = 'const FALLBACK_CONFIG = '
      start = html.index(marker)
      raise 'const FALLBACK_CONFIG = not found' unless start

      i = start + marker.length
      i += 1 while i < html.length && html[i].match?(/\s/)
      raise 'expected { after FALLBACK_CONFIG' unless html[i] == '{'

      open_i = i
      depth = 0
      in_string = nil
      escape = false
      idx = open_i
      while idx < html.length
        c = html[idx]
        if in_string
          if escape
            escape = false
          elsif c == '\\'
            escape = true
          elsif c == in_string
            in_string = nil
          end
        elsif idx + 1 < html.length && c == '/' && html[idx + 1] == '/'
          nl = html.index("\n", idx)
          idx = nl ? nl : html.length - 1
        elsif c == '{'
          depth += 1
        elsif c == '}'
          depth -= 1
          if depth.zero?
            return html[(open_i + 1)...idx]
          end
        elsif c == "'" || c == '"'
          in_string = c
        end
        idx += 1
      end

      raise 'unclosed { in FALLBACK_CONFIG'
    end
  end
end
