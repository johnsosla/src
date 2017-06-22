/*******************************************************************************
*
* PURPOSE: Decorator for Note object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public with sharing class GFA_Note extends GFA_BaseModel {

    public static Finder find = new Finder('Note');

    public Note obj {
        get {
            return (Note)mObj;
        }
    }

    public GFA_Note() {
        this(new Note());
    }

    public GFA_Note(Note note) {
        super(note);
    }

    public String getTitle() {
        return obj.Title;
    }
    public void setTitle(String title) {
        obj.Title = title;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public GFA_Note findById(Id noteId) {
            Note note = (Note)byId(noteId);
            return new GFA_Note(note);
        }

        public List<GFA_Note> findByProjectId(Id projectId) {
            List<GFA_Note> notes = new List<GFA_Note>();
            for (Note note : (List<Note>)Database.query(
                        getSelect() + ' where ParentId =: projectId')) {
                notes.add(new GFA_Note(note));
            }
            return notes;
        }
    }
}