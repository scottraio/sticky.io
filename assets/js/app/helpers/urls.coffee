window.account_forms_path 		= (account_id) 	-> "/accounts/#{ account_id }/forms"
window.account_reports_path 	= (account_id) 	-> "/accounts/#{ account_id }/reports"
window.book_import_path			= (book_id, id)	-> "/books/#{ book_id }/imports/#{ id }"
window.book_imports_path		= (book_id)		-> "/books/#{ book_id }/imports"
window.report_fields_path 		= (report_id) 	-> "/reports/#{ report_id }/fields"

window.admin_templates_path = () -> "/admin/templates"
window.admin_template_screenshots_path = (template_id) -> "/admin/templates/#{ template_id }/screenshots"
