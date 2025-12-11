# Actionable Notifications Examples

This document provides practical examples for testing the new actionable notifications feature in Bark.

## Basic Example

Simple notification with two action buttons:

```bash
curl -X "POST" "https://api.day.app/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d '{
  "title": "Deploy Status",
  "body": "Application v2.0 ready to deploy",
  "actions": "[{\"title\":\"Deploy\",\"url\":\"https://example.com/deploy\",\"foreground\":true},{\"title\":\"Cancel\",\"destructive\":true}]"
}'
```

## Multiple Actions Example

Notification with multiple action buttons (up to 4):

```bash
curl -X "POST" "https://api.day.app/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d '{
  "title": "Server Alert",
  "body": "High CPU usage detected on server-01",
  "actions": "[{\"title\":\"View Dashboard\",\"url\":\"https://monitoring.example.com\"},{\"title\":\"Restart\",\"id\":\"restart\",\"authenticationRequired\":true},{\"title\":\"Investigate\",\"url\":\"https://logs.example.com\",\"foreground\":true},{\"title\":\"Dismiss\",\"id\":\"dismiss\"}]"
}'
```

## URL Scheme Example

Using URL schemes to open specific app views:

```bash
curl -X "POST" "https://api.day.app/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d '{
  "title": "New Message",
  "body": "You have a new message from John",
  "actions": "[{\"title\":\"Reply\",\"url\":\"sms://\"},{\"title\":\"Call\",\"url\":\"tel://+1234567890\"}]"
}'
```

## Destructive Action Example

Using destructive actions for important operations:

```bash
curl -X "POST" "https://api.day.app/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d '{
  "title": "Backup Ready",
  "body": "Database backup completed. Old backups can be deleted.",
  "actions": "[{\"title\":\"Delete Old\",\"destructive\":true,\"authenticationRequired\":true},{\"title\":\"Keep All\"}]"
}'
```

## Combined with Other Features

Actionable notifications can be combined with other Bark features:

```bash
curl -X "POST" "https://api.day.app/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d '{
  "title": "Payment Received",
  "body": "New payment of $99.99",
  "group": "payments",
  "icon": "https://example.com/payment-icon.png",
  "sound": "bell",
  "badge": 1,
  "actions": "[{\"title\":\"View Details\",\"url\":\"https://example.com/payment/123\"},{\"title\":\"Send Receipt\",\"id\":\"receipt\"}]"
}'
```

## Testing Notes

1. **Maximum Actions**: You can define up to 4 custom actions per notification.
2. **Default Actions**: If space permits, default "Copy" and "Mute" actions will still appear.
3. **URL Handling**: Actions with URLs will open the URL when tapped. Actions without URLs will simply dismiss the notification.
4. **Authentication**: Actions with `authenticationRequired: true` will require device unlock before execution.
5. **Foreground**: Actions with `foreground: true` will launch the app in the foreground when tapped.
6. **Destructive Style**: Actions with `destructive: true` will appear in red to warn users.

## Action Properties Reference

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `title` | String | Yes | The text displayed on the action button |
| `id` | String | No | Unique identifier for the action (auto-generated if not provided) |
| `url` | String | No | URL to open when action is tapped (supports URL schemes and Universal Links) |
| `destructive` | Boolean | No | Display action in red (default: false) |
| `authenticationRequired` | Boolean | No | Require device unlock (default: false) |
| `foreground` | Boolean | No | Launch app in foreground (default: false) |

## Integration with bark-server

For server-side integration, ensure your bark-server passes the `actions` parameter through to APNs. The actions should be sent as a JSON string in the notification payload.

Example server payload:
```json
{
  "title": "Test Notification",
  "body": "This is a test",
  "actions": "[{\"title\":\"Action 1\",\"url\":\"https://example.com\"},{\"title\":\"Action 2\",\"id\":\"action2\"}]"
}
```
