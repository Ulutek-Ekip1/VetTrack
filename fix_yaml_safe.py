import sys
from ruamel.yaml import YAML

yaml = YAML()
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=4, offset=2)

file_path = "docs/openapi.yaml"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        data = yaml.load(f)
except Exception as e:
    print(f"Error loading yaml: {e}")
    sys.exit(1)

# Ensure paths dictionary exists
if 'paths' not in data:
    data['paths'] = {}

schemas = data['components']['schemas']

# Remove attachmentUrl from Treatment requests
for req in ['TreatmentCreateRequest', 'TreatmentUpdateRequest']:
    if req in schemas and 'properties' in schemas[req]:
        if 'attachmentUrl' in schemas[req]['properties']:
            del schemas[req]['properties']['attachmentUrl']

# Add new schemas
schemas['AttachmentUploadRequest'] = {
    'type': 'object',
    'properties': {
        'contentType': {'type': 'string'},
        'fileSize': {'type': 'integer', 'format': 'int64'}
    },
    'required': ['contentType', 'fileSize']
}

schemas['AttachmentUrlResponse'] = {
    'type': 'object',
    'properties': {
        'url': {'type': 'string'}
    }
}

# Add new endpoints
paths = data['paths']

paths['/api/treatments/{id}/attachment/upload-url'] = {
    'post': {
        'tags': ['Tedavi Yönetimi'],
        'summary': "İmzalı Yükleme URL'i Al (Upload URL)",
        'operationId': 'generateUploadUrl',
        'security': [{'bearerAuth': []}],
        'parameters': [
            {
                'name': 'id',
                'in': 'path',
                'required': True,
                'schema': {'type': 'string', 'format': 'uuid'}
            }
        ],
        'requestBody': {
            'content': {
                'application/json': {
                    'schema': {'$ref': '#/components/schemas/AttachmentUploadRequest'}
                }
            }
        },
        'responses': {
            '200': {
                'description': 'OK',
                'content': {
                    'application/json': {
                        'schema': {'$ref': '#/components/schemas/AttachmentUrlResponse'}
                    }
                }
            },
            '401': {'$ref': '#/components/responses/Unauthorized'},
            '403': {'$ref': '#/components/responses/Forbidden'}
        }
    }
}

paths['/api/treatments/{id}/attachment/read-url'] = {
    'get': {
        'tags': ['Tedavi Yönetimi'],
        'summary': "İmzalı Okuma URL'i Al (Read URL)",
        'operationId': 'generateReadUrl',
        'security': [{'bearerAuth': []}],
        'parameters': [
            {
                'name': 'id',
                'in': 'path',
                'required': True,
                'schema': {'type': 'string', 'format': 'uuid'}
            }
        ],
        'responses': {
            '200': {
                'description': 'OK',
                'content': {
                    'application/json': {
                        'schema': {'$ref': '#/components/schemas/AttachmentUrlResponse'}
                    }
                }
            },
            '401': {'$ref': '#/components/responses/Unauthorized'},
            '403': {'$ref': '#/components/responses/Forbidden'}
        }
    }
}


with open(file_path, "w", encoding="utf-8") as f:
    yaml.dump(data, f)
print("Updated YAML successfully!")
