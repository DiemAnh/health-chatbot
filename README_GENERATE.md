# Health Chatbot - Clean Architecture Setup

## Cài đặt OpenAPI Generator

### Cách 1: Dùng Homebrew (macOS)
```bash
brew install openapi-generator
```

### Cách 2: Dùng Docker
```bash
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i /local/swagger/swagger.json \
  -g dart \
  -o /local/lib/data/models/generated/
```

### Cách 3: Dùng NPM
```bash
npm install -g @openapitools/openapi-generator-cli
```

## Cài đặt Melos

```bash
# Cài đặt melos globally
dart pub global activate melos

# Bootstrap workspace
melos bootstrap
```

## Cách sử dụng OpenAPI để generate models

1. **Đặt file `swagger.json`** vào thư mục `swagger/` ✅ (đã có)

2. **Cài đặt dependencies:**
   ```bash
   melos pub:get
   ```

3. **Generate models:**
   ```bash
   melos generate
   ```

   Hoặc chạy trực tiếp:
   ```bash
   openapi-generator-cli generate -i swagger/swagger.json -g dart -o lib/data/models/generated/ \
     --package-name health_chatbot.models \
     --additional-properties=pubName=health_chatbot,pubVersion=0.1.0
   ```

## Scripts hữu ích với Melos

- `melos analyze` - Phân tích code
- `melos format` - Format code
- `melos test` - Chạy tests
- `melos clean` - Clean build
- `melos pub:get` - Cài đặt dependencies
- `melos generate` - Generate models from OpenAPI spec

## Cấu trúc

- **Domain**: 
  - Entities
  - Repositories (interfaces)
  - Use Cases (interfaces + impl)
- **Data**: Models (generated), Repositories (impl), DataSources
- **Presentation**: UI, Bloc
- **Core**: DI, Utils, UseCase base
- **Infrastructure**: Network, Database

## Sử dụng Use Cases (Khuyến nghị)

```dart
import 'package:health_chatbot/core/di/injection.dart';

final getAdviceUseCase = getIt<GetHealthAdviceUseCase>();
final advice = await getAdviceUseCase('Tôi bị đau đầu');

final getHistoryUseCase = getIt<GetChatHistoryUseCase>();
final history = await getHistoryUseCase(NoParams());

final sendMessageUseCase = getIt<SendMessageUseCase>();
await sendMessageUseCase(Message(id: '1', content: 'Hello', sender: 'User', timestamp: DateTime.now()));
```

## Sử dụng Repository (Trực tiếp - Không khuyến nghị)

```dart
import 'package:health_chatbot/core/di/injection.dart';

final repo = getIt<HealthRepository>();
final advice = await repo.getHealthAdvice('Tôi bị đau đầu');
```

## Chuyển đổi Mock/Real

Trong `lib/core/di/injection.dart`, comment/uncomment để chuyển đổi giữa mock và real implementation.