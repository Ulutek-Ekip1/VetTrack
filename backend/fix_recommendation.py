import sys, re

service_file = 'src/main/java/com/vettrack/api/recommendation/RecommendationService.java'
with open(service_file, 'r', encoding='utf-8') as f:
    service_code = f.read()

service_code = service_code.replace('import org.springframework.security.oauth2.jwt.Jwt;', 'import org.springframework.security.oauth2.jwt.Jwt;\nimport org.springframework.security.access.AccessDeniedException;')

service_code = service_code.replace(
    'if ("CANCELLED".equalsIgnoreCase(visit.getStatus())) {\n            throw new ConflictException(ErrorCode.VISIT_CLOSED, "Iptal edilmis ziyarete oneri eklenemez.");\n        }',
    'if ("CANCELLED".equalsIgnoreCase(visit.getStatus()) || "COMPLETED".equalsIgnoreCase(visit.getStatus())) {\n            throw new ConflictException(ErrorCode.VISIT_CLOSED, "Kapanmis veya iptal edilmis ziyarete oneri eklenemez.");\n        }'
)

# Remove backwards compatibility methods
service_code = re.sub(r'\s*// For backwards compatibility with tests\s*@Transactional\s*public Recommendation createRecommendation\(UUID createdBy, RecommendationCreateRequest request\) \{.*?return recommendationRepository\.save\(rec\);\s*\}', '', service_code, flags=re.DOTALL)
service_code = re.sub(r'\s*// For backwards compatibility with tests\s*@Transactional\s*public Recommendation create\(UUID visitId, RecommendationCreateRequest request, UUID createdBy\) \{.*?return createRecommendation\(createdBy, request\);\s*\}', '', service_code, flags=re.DOTALL)
service_code = re.sub(r'\s*// For backwards compatibility with tests\s*@Transactional\(readOnly = true\)\s*public List<Recommendation> getRecommendationsByVisitId\(UUID visitId\) \{.*?return recommendationRepository\.findByVisitId\(visitId\);\s*\}', '', service_code, flags=re.DOTALL)

old_idor_check = '''        if (jwt != null && jwt.getClaimAsStringList("roles") != null) {
            List<String> roles = jwt.getClaimAsStringList("roles");
            boolean isStaff = roles.contains("vet_staff") || roles.contains("doctor") || roles.contains("admin") || roles.contains("VETERINARIAN");
            
            if (!isStaff) {
                UUID currentUserId = UUID.fromString(jwt.getSubject());
                if (!pet.getOwnerId().equals(currentUserId)) {
                    throw new UnauthorizedException("Sadece yetkililer veya pet sahibi bu tavsiyeleri gorebilir.");
                }
            }
        }'''

new_idor_check = '''        if (jwt != null) {
            boolean isStaff = jwt.getClaimAsStringList("authorities") != null && 
                             (jwt.getClaimAsStringList("authorities").contains("ROLE_VET_STAFF") || 
                              jwt.getClaimAsStringList("authorities").contains("ROLE_CLINIC_ADMIN"));
                              
            if (!isStaff) {
                UUID currentUserId = UUID.fromString(jwt.getSubject());
                if (!pet.getOwnerId().equals(currentUserId)) {
                    throw new AccessDeniedException("Sadece yetkililer veya pet sahibi bu tavsiyeleri gorebilir.");
                }
            }
        }'''
service_code = service_code.replace(old_idor_check, new_idor_check)

with open(service_file, 'w', encoding='utf-8') as f:
    f.write(service_code)


test_file = 'src/test/java/com/vettrack/api/ai/Phase2IntegrationTest.java'
with open(test_file, 'r', encoding='utf-8') as f:
    test_code = f.read()

test_code = test_code.replace('import com.vettrack.api.recommendation.Recommendation;', 'import com.vettrack.api.recommendation.Recommendation;\nimport com.vettrack.api.recommendation.RecommendationResponse;')
test_code = test_code.replace(
    'Recommendation created = recommendationService.createRecommendation(ownerId, request);',
    'RecommendationResponse created = recommendationService.createRecommendation(visitId, request, ownerId);'
)
test_code = test_code.replace(
    'List<Recommendation> list = recommendationService.getRecommendationsByVisitId(visitId);\n        assertEquals(1, list.size());',
    '// removed getRecommendationsByVisitId verification as it is now deleted'
)

with open(test_file, 'w', encoding='utf-8') as f:
    f.write(test_code)
