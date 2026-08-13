import sys, re

# 1. Update AuthService.java
auth_file = 'src/main/java/com/vettrack/api/auth/AuthService.java'
with open(auth_file, 'r', encoding='utf-8') as f:
    auth_code = f.read()

auth_code = re.sub(
    r'log\.error\(\"Supabase password recovery failed with status \{\}: \{\}\", status\.value\(\), ex\.getResponseBodyAsString\(\)\);\s*throw new RuntimeException\(\"Password recovery failed: \" \+ ex\.getMessage\(\), ex\);\s*\} catch \(Exception ex\) \{\s*log\.error\(\"Supabase password recovery failed: \{\}\", ex\.getMessage\(\)\);\s*throw new RuntimeException\(\"Password recovery failed: \" \+ ex\.getMessage\(\), ex\);\s*\}',
    r'log.error(\"Supabase password recovery failed with status {}: {}\", status.value(), ex.getResponseBodyAsString());\n        } catch (Exception ex) {\n            log.error(\"Supabase password recovery failed: {}\", ex.getMessage());\n        }',
    auth_code
)
with open(auth_file, 'w', encoding='utf-8') as f:
    f.write(auth_code)

# 2. Update JwtAuthenticationFilter.java
jwt_file = 'src/main/java/com/vettrack/api/auth/JwtAuthenticationFilter.java'
with open(jwt_file, 'r', encoding='utf-8') as f:
    jwt_code = f.read()

if 'ObjectMapper' not in jwt_code:
    jwt_code = jwt_code.replace(
        'import jakarta.servlet.http.HttpServletResponse;',
        'import jakarta.servlet.http.HttpServletResponse;\nimport com.fasterxml.jackson.databind.ObjectMapper;\nimport java.util.Map;\nimport java.util.HashMap;\nimport java.time.LocalDateTime;'
    )

    jwt_code = jwt_code.replace(
        'public class JwtAuthenticationFilter extends OncePerRequestFilter {',
        'public class JwtAuthenticationFilter extends OncePerRequestFilter {\n\n    private final ObjectMapper objectMapper = new ObjectMapper();\n\n    private void writeErrorResponse(HttpServletResponse response, int status, String errorCode, String message) throws java.io.IOException {\n        response.setStatus(status);\n        response.setContentType(\"application/json\");\n        response.setCharacterEncoding(\"UTF-8\");\n        Map<String, Object> errorDetails = new HashMap<>();\n        errorDetails.put(\"timestamp\", LocalDateTime.now().toString());\n        errorDetails.put(\"status\", status);\n        errorDetails.put(\"error\", errorCode);\n        errorDetails.put(\"message\", message);\n        response.getWriter().write(objectMapper.writeValueAsString(errorDetails));\n    }'
    )

    jwt_code = jwt_code.replace(
        'response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);\n                    response.getWriter().write(\"User account is inactive or deleted.\");',
        'writeErrorResponse(response, HttpServletResponse.SC_UNAUTHORIZED, \"ACCOUNT_INACTIVE\", \"User account is inactive or deleted.\");'
    )

    jwt_code = jwt_code.replace(
        'response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);\n                response.getWriter().write(\"Database error during authentication.\");',
        'writeErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, \"INTERNAL_SERVER_ERROR\", \"Database error during authentication.\");'
    )

with open(jwt_file, 'w', encoding='utf-8') as f:
    f.write(jwt_code)

# 3. Update PetController.java
pet_file = 'src/main/java/com/vettrack/api/pet/PetController.java'
with open(pet_file, 'r', encoding='utf-8') as f:
    pet_code = f.read()

pet_code = re.sub(
    r'\@GetMapping\(\"\/\{id\}\/visits\"\).*?public ResponseEntity\<Page\<Visit\>\> getPetVisitsPaginated\([^\{]+\{.*?return ResponseEntity\.ok\(visits\);\s*\}',
    '',
    pet_code,
    flags=re.DOTALL
)

pet_code = pet_code.replace('import com.vettrack.api.visit.VisitService;\n', '')
pet_code = pet_code.replace('import com.vettrack.api.visit.Visit;\n', '')
pet_code = pet_code.replace('private final VisitService visitService;\n', '')

pet_code = pet_code.replace('boolean isStaffOrAdmin = isVetOrAdmin(jwt);', 'boolean isStaffOrAdmin = isVetOrAdmin();')

pet_code = re.sub(
    r'private static final java\.util\.Set\<String\> ALLOWED_STAFF_ROLES.*?\@SuppressWarnings\(\"unchecked\"\)\s*private boolean isVetOrAdmin\(Jwt jwt\).*?return false;\s*\}',
    '',
    pet_code,
    flags=re.DOTALL
)

with open(pet_file, 'w', encoding='utf-8') as f:
    f.write(pet_code)

