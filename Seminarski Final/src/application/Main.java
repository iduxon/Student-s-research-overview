package application;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.swing.JOptionPane;

import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

public class Main extends Application {

	static {
		try {
			Class.forName("com.ibm.db2.jcc.DB2Driver");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	static String USER = " ";
	static String PASS = " ";
	static String PRAVA = " ";
	static String ImePrezime = " ";
	static String CBItem = " ";

	Connection con = null;

	// Login Pane Items

	@FXML
	Pane loginPane = new Pane();

	@FXML
	TextField user = new TextField();

	@FXML
	PasswordField pass = new PasswordField();

	@FXML
	Button login = new Button();

	@FXML
	Label loginFail = new Label();

	// End of Login Pane Items

	// Welcome Pane Items

	@FXML
	Pane welcomePane = new Pane();

	@FXML
	Label IzaberiRad = new Label();

	@FXML
	final ChoiceBox<String> Radovi = new ChoiceBox<>();

	@FXML
	Button UcitajRadove = new Button();

	@FXML
	ListView<String> PregledRadova = new ListView<String>();

	@FXML
	Button Report = new Button();

	// LABELS

	@FXML
	Label Studenti = new Label();

	@FXML
	Label Nazivkonferencije = new Label();

	@FXML
	Label ImeiPrezProf = new Label();

	@FXML
	Label Nazivpredmeta = new Label();

	@FXML
	Label Datumkonferencije = new Label();

	@FXML
	Label Opisrada = new Label();

	@FXML
	Button logout = new Button();

	@FXML
	Label ImeiPrezime = new Label();

	@FXML
	Label Korisnik = new Label();

	@FXML
	Label GreskaStudent = new Label();

	// End of welcome pane items

	public void logout() {
		Stage stage2 = (Stage) welcomePane.getScene().getWindow();
		stage2.close();
		ImePrezime = " ";
		try {
			AnchorPane root = (AnchorPane) FXMLLoader.load(Main.class.getResource("Forma.fxml"));
			Stage stage = new Stage();
			stage.setTitle("Pregled studentskih seminarskih i istraživačkih radova");
			stage.setScene(new Scene(root));

			stage.show();

		}

		catch (IOException e) {
			e.printStackTrace();
		}

	}

	// Setting the Name and Surname in label
	public void ImePrezime() {
		ImeiPrezime.setText(ImePrezime);
	}

	public void login() {
		try {
			con = DriverManager.getConnection("jdbc:db2://localhost:50000/sem2014", "db2admin", "db2pass");

			// We check the userID pass and access rights from "autorization" table
			PreparedStatement PS = con.prepareStatement("SELECT USERID,PASSWORD,PRAVA " + " FROM autorizacija "
					+ " WHERE USERID=? AND PASSWORD=? AND (PRAVA = 0 OR PRAVA = 1 OR PRAVA = 2)");

			USER = user.getText();
			PASS = pass.getText();

			PS.setString(1, USER);
			PS.setString(2, PASS);

			ResultSet rs = PS.executeQuery();

			// Deleting the white spaces and getting the catalog of users
			PreparedStatement PS1 = con
					.prepareStatement("SELECT replace(d.ime,' ','') ||' '|| replace(d.prezime,' ','') "
							+ " FROM autorizacija a join dosije d on d.userid = a.userid" + " WHERE a.USERID=?");

			PS1.setString(1, USER);

			ResultSet rs1 = PS1.executeQuery();

			// Deleting the white spaces and getting the catalog of teachers
			PreparedStatement PS2 = con
					.prepareStatement("SELECT replace(n.ime,' ','') ||' '|| replace(n.prezime,' ','') "
							+ " FROM autorizacija a join nastavnik n on a.userid = n.userid  " + " WHERE a.USERID=?");

			PS2.setString(1, USER);

			ResultSet rs2 = PS2.executeQuery();

			while (rs1.next()) {
				ImePrezime = rs1.getString(1);
			}

			if (ImePrezime == " ") {
				while (rs2.next()) {
					ImePrezime = rs2.getString(1);
				}
			}

			int konektovan = 0;

			// if the user exists,a window is opened with research reports, and keeps his
			// access rights stored
			while (rs.next()) {

				PRAVA = rs.getString(3);
				konektovan = 1;

				Stage stage1 = (Stage) user.getScene().getWindow();
				stage1.close();

				try {
					AnchorPane root = (AnchorPane) FXMLLoader.load(Main.class.getResource("report.fxml"));
					Stage stage = new Stage();
					stage.setTitle("Pregled studentskih istraživačkih radova");
					stage.setScene(new Scene(root));

					stage.show();

				}

				catch (IOException e) {
					e.printStackTrace();
				}
			}

			if (konektovan == 0) {
				loginFail.setVisible(true);
			}

			rs.close();
			PS.close();
			rs1.close();
			PS1.close();
			rs2.close();
			PS2.close();
		}

		catch (Exception e) {
			e.printStackTrace();
		}
	}

	// Fill the research observable list with researches from database
	public void setItems() {
		try {
			con = DriverManager.getConnection("jdbc:db2://localhost:50000/sem2014", "db2admin", "db2pass");
			Statement stmt = con.createStatement();

			ResultSet rs = stmt.executeQuery("SELECT NAZIVRADA " + " FROM istrazivackirad ");

			ObservableList<String> Items = FXCollections.observableArrayList();

			while (rs.next()) {

				Items.add(rs.getString(1));

			}

			Radovi.setItems(Items);

			rs.close();

		}

		catch (Exception e) {
			e.printStackTrace();
		}

	}

	public void setReports() throws SQLException {

		PreparedStatement PS;
		PreparedStatement PS1;
		try {
			CBItem = Radovi.getValue();
			con = DriverManager.getConnection("jdbc:db2://localhost:50000/sem2014", "db2admin", "db2pass");

			// Get the research presentation , name of conferention, name ,surname, name of
			// subject, date of conferention, presentation title
			// where the teacher ids match the research presentation and subject id with
			// research presentation id
			// and we fill the name of research in prepared statement
			PS = con.prepareStatement(
					"SELECT iz.SPISAKDOSIJEA, NAZIVKONF, replace(IME,' ','')|| ' ' ||replace(PREZIME,' ',''), p.NAZIV, DATUMKONF, iz.OPIS "
							+ "FROM IZLAGANJERADA iz join istrazivackirad ir " + "on iz.id_rada=ir.id_rada "
							+ "join nastavnik n "
							+ "on n.id_nastavnika = iz.id_nastavnika and n.id_nastavnika = ir.id_nastavnika "
							+ "join predmet p "
							+ "on iz.id_predmeta = p.id_predmeta and ir.id_predmeta = p.id_predmeta "
							+ "WHERE ir.nazivrada = ? ");

			ObservableList<String> Items = FXCollections.observableArrayList();

			PS.setString(1, CBItem);

			ResultSet rs = PS.executeQuery();

			// get the list of records from research where the subject is PreparedStatement
			PS1 = con.prepareStatement("select spisakdosijea " + "from istrazivackirad " + "WHERE nazivrada = ?");

			PS1.setString(1, CBItem);

			ResultSet rs1 = PS1.executeQuery();

			// if a name doesnt have rights to be in this research ,add an empty string,and
			// add it to the listView
			while (rs1.next()) {
				if (!(rs1.getString(1).toLowerCase().contains(ImePrezime.toLowerCase())) && PRAVA.equals("2")) {
					GreskaStudent.setText("You did not participate in this research!");
					for (int i = 1; i < 7; i++) {
						Items.add("");
					}
					PregledRadova.setItems(Items);
					return;
				}
			}

			while (rs.next()) {
				GreskaStudent.setText("");
				for (int i = 1; i < 7; i++) {
					Items.add(rs.getString(i));
				}
			}

			PregledRadova.setItems(Items);
			rs.close();
			PS.close();
			rs1.close();
			PS1.close();

		}

		// if we catch invalid character or deadlock we wait and rollback
		catch (SQLException e) {
			if (e.getErrorCode() == -911 || e.getErrorCode() == -913) {
				JOptionPane.showMessageDialog(null, "Object is locked\n. Wait...");
				try {
					con.rollback();
				} finally {
					System.out.println("Rollback\n");
				}
			}
		}

	}

	@Override
	public void start(Stage primaryStage) {
		try {

			AnchorPane root = (AnchorPane) FXMLLoader.load(Main.class.getResource("Forma.fxml"));

			Scene scene = new Scene(root);

			scene.getStylesheets().add(getClass().getResource("application.css").toExternalForm());

			primaryStage.setScene(scene);

			primaryStage.setTitle("Overview of student's research papers");
			primaryStage.show();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		launch(args);
	}
}
