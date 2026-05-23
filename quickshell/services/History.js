.pragma library

// Append `value` to a rolling array, dropping the oldest past `maxLen`.
function push(arr, value, maxLen) {
    const next = arr.slice();
    next.push(value);
    if (next.length > maxLen)
        next.shift();
    return next;
}
