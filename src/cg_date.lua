local CGDate = {}
function CGDate.get_numeric()
    return os.date("%d/%m/%Y")
end
return CGDate
