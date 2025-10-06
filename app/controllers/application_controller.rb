class ApplicationController < ActionController::Base

  def home
    if request.post?
      begin
        files = params[:files]
        parsed_data = process_files(files)
        @days = data_to_days(parsed_data)
        mark_traveling(@days)
        calculate(@days)
      rescue => e
        raise e
      end
    end
  end

  private

  # process the provided files and use a regex to get the valid data into an array, one entry per line
  def process_files(files)
    projects = []
    date_format = '%m/%d/%y'
    regex = /Project (?<project_number>\d+): (?<high_low>high|low) Cost City Start Date: (?<start_date>\d{1,2}\/\d{1,2}\/\d{2}) End Date: (?<end_date>\d{1,2}\/\d{1,2}\/\d{2})/i
    
    files.each do |file|
      File.foreach(file.tempfile.path) do |line|
        match = line.match(regex)

        if match
          projects.push({
            project_number: match['project_number'],
            cost:           match['high_low'],
            start_date:     Date.strptime(match['start_date'], date_format),
            end_date:       Date.strptime(match['end_date'], date_format)
          })
        end

      end
    end
    projects
  end

  # take the array of data points and create a hash of entries, using the date timestamp as the key
  # when adding new entries, high cost wins
  def data_to_days(projects)
    dates = {}

    projects.each do |project|
      (project[:start_date]..project[:end_date]).each do |date|
        current_date = dates[date]

        if current_date.nil?
          dates[date] = {cost: project[:cost], project_number: [project[:project_number]]}
        else
          current_date[:cost] = project[:cost] == 'High' ? 'High' : current_date[:cost]
          current_date[:project_number].push(project[:project_number])
        end

      end
    end
    
    dates
  end

  # loop over the dates in chronological order and mark each one as traveling or full
  def mark_traveling(dates)
    dates.keys.sort.each do |date|
      value = dates[date]
      dates[date][:type] = (dates[date - 1.day] && dates[date + 1.day]) ? 'full' : 'travel'
    end
  end

  # calculate the amount for each day and store it on the day object
  def calculate(dates)
    amounts = {
      cost: {
        low: 45,
        high: 75
      },
      type: {
        travel: 0,
        full: 10
      }
    }

    dates.each do |date, info|
      info[:amount] = 0
      amounts.keys.each do |attr|
        puts amounts[attr]
        puts info[attr]
        info[:amount] += amounts[attr][info[attr].downcase.to_sym]
      end
    end
  end
end
