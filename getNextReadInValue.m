%Acts like a queue in the sense that it takes the first value from the
%passed array and assigned it to readInValue. Then, it removes that value
%from the array.
function readInValue = getNextReadInValue (readInArray)
    readInValue = readInArray(1);
    readInArray = readInArray(2:end);
end

