---
name: laravel-service-action-architecture
description: Use when developing, refactoring, or architecting backend applications in Laravel and PHP following Thin Controller and Fat Action patterns.
---

# Laravel "Thin Controller, Fat Service / Action" Architecture

Controllers in Laravel should only handle HTTP concerns (request intake, authorization check, calling domain logic, returning HTTP response). Business logic must reside in dedicated **Action** or **Service** classes.

## Standard Directory Structure

```text
app/
├── Http/
│   ├── Controllers/          # Thin controllers (3-7 lines per method)
│   ├── Requests/             # FormRequests for validation & authorization
│   └── Resources/            # API Resources for JSON serialization
├── Actions/                  # Single-purpose action classes (e.g. CreateUserAction)
├── Services/                 # Multi-method business services (e.g. PaymentGatewayService)
└── Data/                     # Data Transfer Objects (DTOs / Spatie Laravel Data)
```

## Architectural Pattern Example

### 1. Dedicated Action Class (`app/Actions/RegisterStudentAction.php`)
```php
namespace App\Actions;

use App\Models\User;
use App\Models\Student;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class RegisterStudentAction
{
    public function execute(array $data): Student
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
            ]);

            return Student::create([
                'user_id' => $user->id,
                'npm' => $data['npm'],
                'jurusan' => $data['jurusan'],
            ]);
        });
    }
}
```

### 2. Thin Controller (`app/Http/Controllers/StudentController.php`)
```php
namespace App\Http\Controllers;

use App\Http\Requests\RegisterStudentRequest;
use App\Actions\RegisterStudentAction;
use App\Http\Resources\StudentResource;
use Illuminate\Http\JsonResponse;

class StudentController extends Controller
{
    public function store(RegisterStudentRequest $request, RegisterStudentAction $action): JsonResponse
    {
        $student = $action->execute($request->validated());

        return response()->json([
            'message' => 'Student successfully registered',
            'data' => new StudentResource($student),
        ], 201);
    }
}
```

## Golden Rules
1. **Never write complex DB queries or raw business logic inside Controllers**: Delegate to Actions or Query Scopes.
2. **Never use `$request->all()` directly**: Always validate via `FormRequest` and use `$request->validated()`.
3. **Wrap multi-table mutations in `DB::transaction()`**: Guarantee data consistency.
4. **100% Testable**: Actions can be unit tested without making full HTTP requests (`(new RegisterStudentAction())->execute(...)`).

