class NormaAEB43File
  FIELD_SEPARATOR = ','
  END_OF_LINE = "\n"
  DATE_SEPARATOR = '-'
  LINE_START = {
    '1120' => :headers,
    '22  ' => :extract_date_and_amount,
    '2301' => :extract_concept,
    '2302' => :worthless_line,
    '2303' => :worthless_line,
    '3320' => :worthless_line,
    '8899' => :close_file
  }
  DEBIT = -1
  CREDIT = 1
  ENTRY_SIGN = { '1' => DEBIT, '2' => CREDIT }

  def initialize(file)
    @bank_file = File.new(file, 'r')
    @csv_file = File.new('output.csv', 'w')
  end

  def parse
    @bank_file.each_line do |line|
      @line = line
      @csv_file.write(send(LINE_START[line[0..3]]))
    end
  end

  private

  def headers
    'DATE,AMOUNT,CONCEPT'
  end

  def extract_date_and_amount
    date = parse_date
    amount = parse_amount
    END_OF_LINE + date + FIELD_SEPARATOR + amount + FIELD_SEPARATOR
  end

  def extract_concept
    format_text(@line[4..76])
  end

  def worthless_line
    nil
  end

  def close_file
    @csv_file.close
  end

  def parse_date
    month = @line[12..13]
    day = @line[14..15]
    year = '20' + @line[16..17]

    month + DATE_SEPARATOR + day + DATE_SEPARATOR + year
  end

  def parse_amount
    multiplier = ENTRY_SIGN[@line[27]]
    amount = @line[28..41].to_i / 100.0 * multiplier
    format_number(amount, '%.2f')
  end

  def format_number(number, format)
    format % number.to_s
  end

  def format_text(concept)
    concept.gsub(',', '').split.join(' ')
  end
end
