-- the google api key has to be saved into the env variable $GOOGLE_API_KEY
-- or passed as an argument to the call with the option -a or --api_key

local youtube = require("yt-data")
local cjson = require("cjson")

local api_key = os.getenv("GOOGLE_API_KEY")  

-- Convert ISO 8601 date to timestamp (milliseconds since epoch).
function timestamp(date_str)
    -- Format: "2020-10-15T13:57:06+00:00"
    local year, month, day, hour, min, sec = date_str:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    local date_table = {
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = min,
        sec = sec
    }
    return os.time(date_table) * 1000
end

-- Generate a random UUID (using math.random).
function generate_uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return (template:gsub("x", function(c)
        local v = math.random(0, 15)
        return string.format("%x", v)
    end):gsub("y", function(c)
        local v = math.random(8, 11)
        return string.format("%x", v)
    end))
end

-- Parse the CSV and convert it to a table.
function parse_csv_to_table(csv)
    local result = {}

    for i, row in ipairs(csv) do
        local video_details = youtube.get_video_info(row.id, api_key)
        local json_item = {
            videoId = row.id,
            title = (video_details ~= nil) and video_details.title or "",
            author = "",
            authorId = (video_details ~= nil) and video_details.channelId or "",
            lengthSeconds = "0:00",
            timeAdded = timestamp(row.creation_date),
            playlistItemId = generate_uuid(),
            type = "video"
        }
        table.insert(result, json_item)
    end

    return result 
end

-- Read CSV file and return the rows as a table
function read_csv(file_name)
    local csv = {}
    local file = io.open(file_name, "r")
    if not file then
        print("Could not open file: " .. file_name)
        return
    end

    -- Read header (ignore it)
    file:read() -- Skip the header line

    -- Read each line of the CSV
    for line in file:lines() do
        local id, creation_date = line:match("([^,]+),([^,]+)")
        if id and creation_date then
            table.insert(csv, { id = id, creation_date = creation_date })
        end
    end

    file:close()
    return csv
end

----------------------------
-- Main program execution --
----------------------------

-- Reading the input
local filename_index = 1
if arg[1] == "-a" or arg[1] == "--api-key" then
   api_key = arg[2]
   filename_index = 3
end
local file_name = arg[filename_index]

if not file_name then
    print("Usage: lua script.lua <csv_file>")
    os.exit(1)
end
-- end reading input.

local csv = read_csv(file_name)
if not csv or #csv == 0 then
    print("No valid CSV data found.")
    os.exit(1)
end

local title = file_name:gsub("%.csv$", "")
local videosArray = parse_csv_to_table(csv)
local playlist = {
    playlistName = title,
    protected = false,
    description = title,
    videos = videosArray,
    _id = generate_uuid(),
    createdAt = os.time() * 1000, 
    lastUpdatedAt = os.time() * 1000
}

local playlistStr = cjson.encode(playlist)
print(playlistStr)

