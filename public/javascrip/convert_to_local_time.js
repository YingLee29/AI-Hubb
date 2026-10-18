function convertToLocalTime(time) {
  const date = new Date(time);

  const convertedTime = date.toLocaleString(undefined, { timeZoneName: "short", hour12: false });

  return convertedTime;
}
