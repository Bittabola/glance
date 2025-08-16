#!/bin/bash

echo "Testing Glance performance..."

URL="http://localhost:8080"

# Check if the server is running
if ! curl -s $URL > /dev/null; then
    echo "❌ Server not running at $URL"
    echo "Start with: docker run -d -p 8080:8080 -v \$(pwd)/config:/app/config glance-fast"
    exit 1
fi

echo "🔍 Testing page load times (5 requests)..."

total_time=0
for i in {1..5}; do
    # Measure time for full page load
    time=$(curl -o /dev/null -s -w '%{time_total}' $URL)
    echo "Request $i: ${time}s"
    total_time=$(echo "$total_time + $time" | bc -l)
done

avg_time=$(echo "scale=3; $total_time / 5" | bc -l)
echo ""
echo "📊 Results:"
echo "  Average load time: ${avg_time}s"

if (( $(echo "$avg_time < 2.0" | bc -l) )); then
    echo "  ✅ Excellent! Under 2 seconds"
elif (( $(echo "$avg_time < 3.0" | bc -l) )); then
    echo "  ✅ Good! Under 3 seconds"
elif (( $(echo "$avg_time < 5.0" | bc -l) )); then
    echo "  ⚠️  OK, but could be better"
else
    echo "  ❌ Slow! Needs optimization"
fi

echo ""
echo "🔍 Testing API content endpoint (widget data)..."
api_time=$(curl -o /dev/null -s -w '%{time_total}' "$URL/api/pages/content/")
echo "  Widget content load time: ${api_time}s"

echo ""
echo "💡 Tips to improve performance:"
echo "  - Reduce cache durations in widgets if they're too high"
echo "  - Check network connectivity to external APIs"
echo "  - Consider removing slow external feeds/APIs"
echo "  - Use docker logs <container-id> to check for errors"
