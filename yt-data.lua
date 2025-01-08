local http = require("socket.http")
local ltn12 = require("ltn12")
local dkjson = require("dkjson")

-- Function to fetch video details from YouTube using the API
local function get_video_info(video_id, api_key)
    -- Construct the YouTube API URL
    local url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=" .. video_id .. "&key=" .. api_key
    local response = {}

    -- Perform the HTTP request to get the YouTube video data
    local _, status = http.request{
        url = url,
        sink = ltn12.sink.table(response)
    }

    -- Check if the request was successful
    if status == 200 then
        -- Combine the response into a single string
        local response_str = table.concat(response)
        
        -- Parse the JSON response using dkjson
        local data, pos, err = dkjson.decode(response_str, 1, nil)
        
        if err then
            print("Error parsing JSON: " .. err)
            return nil
        end

        -- Check if items are returned in the response
        if data.items and #data.items > 0 then
            local video = data.items[1]
           
            -- Create a table to hold the video details
            local video_info = {
                videoId = video.id,
                kind = video.kind,
                etag = video.etag,
                title = video.snippet.title,
                description = video.snippet.description,
                publishedAt = video.snippet.publishedAt,
                channelId = video.snippet.channelId,
                channelTitle = video.snippet.channelTitle,
                channelDescription = video.snippet.description,
                tags = video.snippet.tags,
                categoryId = video.snippet.categoryId,
                thumbnails = video.snippet.thumbnails,
                duration = video.contentDetails.duration,
                dimension = video.contentDetails.dimension,
                definition = video.contentDetails.definition,
                caption = video.contentDetails.caption,
                viewCount = video.statistics.viewCount,
                likeCount = video.statistics.likeCount,
                favoriteCount = video.statistics.favoriteCount,
                commentCount = video.statistics.commentCount
            }
            
            -- Return the video info table
            return video_info
        else
            print("No data found for video ID: " .. video_id)
            return nil
        end
    else
        print("Failed to fetch video details. HTTP Status: " .. status)
        return nil
    end
end

-- Return the functions to make them available to other scripts
return {
    get_video_info = get_video_info
}

