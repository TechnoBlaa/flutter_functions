import functions_framework
from google.cloud import firestore

@functions_framework.http
def delete_document(request):
    request_json = request.get_json()
    if request_json and 'docId' in request_json:
        doc_id = request_json['docId']
        db = firestore.Client()
        db.collection('Componentes').document(doc_id).delete()
        return 'Document deleted successfully', 200
    else:
        return 'Invalid request', 400
