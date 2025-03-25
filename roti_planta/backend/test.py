# @app.route('/test-jamai', methods=['GET'])
# def test_jamai():
#     try:
#         completion = jamai.table.add_table_rows(
#             "action",
#             p.RowAddRequest(
#                 table_id="Report_Analysis",
#                 data=[{
#                     "Report": {
#                         "content": base64.b64encode(b"Test content").decode("utf-8"),
#                         "filename": "test.txt",
#                         "content_type": "text/plain"
#                     }
#                 }],
#                 stream=False,
#             ),
#         )
#         return jsonify({"completion": str(completion)})
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500