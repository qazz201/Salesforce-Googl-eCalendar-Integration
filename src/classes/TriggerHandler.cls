/**
 * Created by Vladyslav Kravchuk on 6/24/2021.
 */

public abstract with sharing class TriggerHandler {
    private TriggerOperation context;
    protected Boolean DISABLE_TRIGGER = false;

    public void execute() {
        if (DISABLE_TRIGGER) return ;

        this.setContext();

        switch on context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
        }
    }

    private void setContext() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) context = TriggerOperation.BEFORE_INSERT;
            if (Trigger.isUpdate) context = TriggerOperation.BEFORE_UPDATE;
            if (Trigger.isDelete) context = TriggerOperation.BEFORE_DELETE;
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) context = TriggerOperation.AFTER_INSERT;
            if (Trigger.isUpdate) context = TriggerOperation.AFTER_UPDATE;
            if (Trigger.isDelete) context = TriggerOperation.AFTER_DELETE;
        }
    }

    protected virtual void beforeInsert() {
    }
    protected virtual void beforeUpdate() {
    }
    protected virtual void beforeDelete() {
    }
    protected virtual void afterInsert() {
    }
    protected virtual void afterUpdate() {
    }
    protected virtual void afterDelete() {
    }

}