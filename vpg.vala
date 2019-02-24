int main () {
	var vpg = new ProjectGenerator ();
	vpg.init_project ();

	return 0;
}

public class ProjectGenerator : Object {
	const string TEMPLATE_PATH = "./elementary-application-template";
	File template_directory = File.new_for_path (TEMPLATE_PATH);
	Template.Scope project_scope = new Template.Scope ();
	string project_id;
	File target_directory;

	public void init_project () {
		//  Fill project scope
		var developer_name = get_string_input ("Developer name");
		var project_name = get_string_input ("Project name");
		project_id = get_string_input ("Project id");
		var project_id_slashed = project_id_slashed (project_id);
		var project_generic_name = get_string_input ("Project generic name");
		var project_summary = get_string_input ("Project summary");
		var project_description = get_string_input ("Project description");
		var project_license = get_project_license ();
		var metadata_license = get_metadata_license ();
		var categories = get_categories ();
		var project_keywords = get_string_input ("Keywords");
		var homepage_url = get_string_input ("Homepage Url");
		var bugtracker_url = get_string_input ("Bugtracker Url");

		project_scope.set_string ("developer_name", developer_name);
		project_scope.set_string ("project_name", project_name);
		project_scope.set_string ("project_id", project_id);
		project_scope.set_string ("slashed_project_id", project_id_slashed);
		project_scope.set_string ("project_generic_name", project_generic_name);
		project_scope.set_string ("project_summary", project_summary);
		project_scope.set_string ("project_description", project_description);
		if (project_license != null) {
			project_scope.set_string ("project_license", project_license);
		}
		project_scope.set_string ("metadata_license", metadata_license);
		project_scope.set_variant ("categories", categories);
		project_scope.set_string ("project_keywords", project_keywords);
		project_scope.set_string ("homepage_url", homepage_url);
		project_scope.set_string ("bugtracker_url", bugtracker_url);

		if (continue ()) {
			target_directory = File.new_for_path (project_name);
			create_project ();
		}
	}

	public void create_project () {
		try {
			target_directory.make_directory ();
			expand_files (template_directory);
		} catch (Error e) {
			print (e.message + "\n");
		}
	}

	void expand_files (File directory) {
		try {
			var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

			FileInfo file_info;
			while ((file_info = enumerator.next_file ()) != null) {
				var file = enumerator.get_child (file_info);

				if (file.query_file_type (FileQueryInfoFlags.NONE) == FileType.DIRECTORY) {
					target_directory.get_child (template_directory.get_relative_path (file)).make_directory ();
					expand_files (file);
				} else {
					File target;

					if (file.get_basename ().has_suffix (".tmpl")) {
						var target_path = template_directory.get_relative_path (file)
							.replace (".tmpl", "")
							.replace ("project_id", project_id);

						print (@"Creating $target_path\n");
						target = target_directory.get_child (target_path);

						var tmpl = new Template.Template (null);
						tmpl.parse_file (file);
						tmpl.expand (target.create (FileCreateFlags.NONE), project_scope);
						//  print (@"$(tmpl.expand_string (project_scope))\n");
					} else {
						var target_path = template_directory.get_relative_path (file)
							.replace ("project_id", project_id);
						print (@"Creating $target_path\n");

						target = target_directory.get_child (target_path);
						file.copy (target, FileCopyFlags.BACKUP);
					}
				}
			}

		} catch (Error e) {
			error (e.message);
		}
	}

	bool continue () {
		print ("\nConfirms(Y/N): ");
		int confirmation = stdin.getc ();
		print ("\n");
		return !(confirmation != 'Y' && confirmation != 'y');
	}

	string get_string_input (string name) {
		print (@"$name: ");
		return stdin.read_line ();
	}

	string project_id_slashed (string project_id) {
		var slashed_project_id = "/" + project_id.replace (".", "/");
		print (@"Project path (resources and schema): $slashed_project_id\n");
		return slashed_project_id;
	}

	string? get_project_license () {
		print ("Project license: (A) GPL 3.0 (B) MIT (C) GPL-2.0 (D) More options\n");
		int project_license_input = stdin.getc ();
		if (project_license_input == 'D' || project_license_input == 'd') {
			print ("(E) LGPL-3.0+ (F) CC-BY-SA-2.0 (Any other character) None\n");
			project_license_input = stdin.getc ();
		}

		string project_license = null;
		switch (project_license_input) {
			case 'A':
			case 'a':
				project_license = "GPL-3.0+";
				break;
			case 'B':
			case 'b':
				project_license = "MIT";
				break;
			case 'C':
			case 'c':
				project_license = "GPL-2.0";
				break;
			case 'E':
			case 'e':
				project_license = "LGPL-3.0+";
				break;
			case 'F':
			case 'f':
				project_license = "CC-BY-SA-2.0";
				break;
		}

		return project_license;
	}

	string get_metadata_license () {
		//  metadata_license
		print ("Metadata license: (A) CC0-1.0 (B) CC-BY-3.0 (C) CC-BY-SA-3.0 (D) Other (I will type)\n");
		int metadata_license_type = stdin.getc ();
		string metadata_license;

		switch (metadata_license_type) {
			case 'A':
			case 'a':
				metadata_license = "CC0-1.0";
				break;
			case 'B':
			case 'b':
				metadata_license = "CC-BY-3.0";
				break;
			case 'C':
			case 'c':
				metadata_license = "CC-BY-SA-3.0";
				break;
			default:
				metadata_license = stdin.read_line ();
				break;
		}

		return metadata_license;
	}

	Variant get_categories () {
		print (@"Categories (separated by commas): \n");
		var categories = stdin.read_line ();
		return new Variant.strv (categories.split (","));
	}
}
