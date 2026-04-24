module Rubyfight
  module FieldMask
    # index.html の FIELD_MASK と同一（行・列・文字）
    ROWS = [
      '          000000000000          ',
      '         00000000000000         ',
      '       000000000000000000       ',
      '     0000000000000000000000     ',
      '   00000000000000000000000000   ',
      ' 000000000000000000000000000000 ',
      '  0000000000000000000000000000  ',
      '   00000000000000000000000000   ',
      '    000000000000000000000000    ',
      '     0000000000000000000000     ',
      '      00000000000000000000      ',
      '       000000000000000000       ',
      '        0000000000000000        ',
      '         00000000000000         ',
      '          000000000000          ',
      '           0000000000           ',
      '            00000000            ',
      '             000000             '
    ].freeze

    def self.row_count
      ROWS.length
    end

    def self.col_count
      return 0 if ROWS.empty?

      ROWS.first.length
    end

    def self.playable?(row, col)
      return false if row.negative? || row >= ROWS.length
      return false if col.negative? || col >= ROWS[row].length

      ROWS[row][col] == '0'
    end

    def self.rectangular?
      w = col_count
      ROWS.all? { |r| r.length == w }
    end
  end
end
