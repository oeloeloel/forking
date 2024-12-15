module Forked
  # Forked story file parser
  class Parser
    class << self
      # The heading line starts a new chunk
      # The heading line begins with a double #
      def parse_heading(line, context, story, line_no)
        return unless line.strip.start_with?('##')

        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        context.delete(:heading)
        context.clear

        line.strip!
        line.delete_prefix!('##')
        line.strip!
        line.delete_prefix!('#')
        line.strip!


        gfm_slug = make_slug(unescape(line, @escapable)) # GFM style header navigation

        if line.include?('{') && line.include?('}')
          line = pull_out('{', '}', line)
        else
          line = [line]
        end

        heading, chunk_id = line
        if heading.empty? && chunk_id.nil?
          raise "Forked: Expected heading and/or ID on line #{line_no + 1}."
        end

        heading = story.title.delete_prefix("#").strip if heading.empty?
        chk = make_chunk_hash

        chk[:id] = unescape(chunk_id, @escapable) if chunk_id
        chk[:slug] = gfm_slug

        hdg = make_heading_hash
        hdg[:text] = unescape(heading, @escapable)

        chk[:content] << hdg

        story[:chunks] << chk
        true
      end

      def make_heading_hash
        {
          type: :heading,
          text: ''
        }
      end
    end
  end
end
