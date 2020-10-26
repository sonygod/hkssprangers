package hkssprangers.browser;

import js.html.Event;
import mui.core.*;
import hkssprangers.info.*;
import hkssprangers.info.ContactMethod;
import hkssprangers.info.PaymentMethod;
import hkssprangers.info.PickupMethod;
using Lambda;
using hkssprangers.MathTools;
using hkssprangers.ObjectTools;
using hkssprangers.info.DeliveryTools;
using hkssprangers.info.TimeSlotTools;

typedef DeliveryViewProps = {
    final delivery:Delivery;
    final onChange:Null<Delivery>->Void;
}

typedef DeliveryViewState = {
    final isEditing:Bool;
    final editingDelivery:Delivery;
}

class DeliveryView extends ReactComponentOf<DeliveryViewProps, DeliveryViewState> {
    function new(props):Void {
        super(props);
        state = {
            isEditing: false,
            editingDelivery: props.delivery.deepClone(),
        }
    }

    function updateOrder(old:Order, updated:Order) {
        setState({
            editingDelivery: state.editingDelivery.with({
                orders: state.editingDelivery.orders.map(o -> o != old ? o : updated),
            }),
        });
    }

    final inputProps = {
        disableUnderline: true,
    }

    final inputLabelProps = {
        shrink: true,
    }

    function renderOrder(key:Dynamic, o:Order) {
        if (state.isEditing) {
            function orderDetailsOnChange(evt:Event) {
                updateOrder(o, o.with({
                    orderDetails: (cast evt.target).value,
                }));
            }
            function customerNoteOnChange(evt:Event) {
                updateOrder(o, o.with({
                    customerNote: switch ((cast evt.target).value:String) {
                        case "": null;
                        case v: v;
                    },
                }));
            }
            function wantTablewareOnChange(evt:Event) {
                updateOrder(o, o.with({
                    wantTableware: (cast evt.target).value,
                }));
            }
            function orderPriceOnChange(evt:Event) {
                updateOrder(o, o.with({
                    orderPrice: Std.parseFloat((cast evt.target).value),
                }));
            }
            return jsx('
                <div key=${key}>
                    <Typography>🔸 ${o.shop.info().name}</Typography>
                    <TextField
                        label="食物內容"
                        variant=${Filled}
                        InputProps=${inputProps}
                        InputLabelProps=${inputLabelProps}
                        multiline
                        fullWidth
                        rowsMax=${cast Math.POSITIVE_INFINITY}
                        value=${o.orderDetails}
                        onChange=${orderDetailsOnChange} />
                    <TextField
                        label="食物備註"
                        variant=${Filled}
                        InputProps=${inputProps}
                        InputLabelProps=${inputLabelProps}
                        multiline
                        fullWidth
                        rowsMax=${cast Math.POSITIVE_INFINITY}
                        value=${o.customerNote != null ? o.customerNote : ""}
                        placeholder="無"
                        onChange=${customerNoteOnChange} />
                    <TextField
                        select
                        label="餐具"
                        variant=${Filled}
                        InputProps=${inputProps}
                        InputLabelProps=${inputLabelProps}
                        fullWidth
                        value=${o.wantTableware}
                        onChange=${wantTablewareOnChange}
                    >
                        <MenuItem value=${true}>要餐具</MenuItem>
                        <MenuItem value=${false}>唔要餐具</MenuItem>
                    </TextField>
                    <TextField
                        label="食物價錢"
                        variant=${Filled}
                        fullWidth
                        type=${Number}
                        InputProps=${inputProps.merge({
                            startAdornment: jsx('<InputAdornment position=${Start}>$$</InputAdornment>'),
                        })}
                        InputLabelProps=${inputLabelProps}
                        value=${o.orderPrice}
                        onChange=${orderPriceOnChange} />
                </div>
            ');
        } else {
            var customerNote = if (o.customerNote != null && o.customerNote != "") {
                jsx('<Typography>⚠️ ${o.customerNote}</Typography>');
            } else {
                null;
            }
            return jsx('
                <div key=${key}>
                    <Typography>🔸 ${o.shop.info().name}</Typography>
                    <Typography className="pre-wrap">${o.orderDetails}</Typography>
                    ${customerNote}
                    <Typography>${o.wantTableware ? "要餐具" : "唔要餐具"}</Typography>
                    <Typography paragraph>食物價錢: $$${o.orderPrice}</Typography>
                </div>
            ');
        }
    }

    function onSave() {
        props.onChange(state.editingDelivery.deepClone());
        setState({
            isEditing: false,
        });
    }

    function onCancel() {
        setState({
            isEditing: false,
            editingDelivery: props.delivery.deepClone(),
        });
    }

    function onDelete() {
        props.onChange(null);
        setState({
            isEditing: false,
        });
    }

    function onEdit() {
        setState({
            isEditing: true,
        });
    }

    override function render() {
        var d = if (!state.isEditing) {
            props.delivery;
        } else {
            state.editingDelivery;
        }
        var foodTotal = d.orders.fold((order:Order, result:Float) -> result + order.orderPrice.nanIfNull(), 0.0);

        var customerPreferredContactMethod = if (!state.isEditing) {
            null;
        } else {
            var contactMethods = [Telegram, WhatsApp].map(m -> {
                jsx('<MenuItem key=${m} value=${m}>${m.info().name}</MenuItem>');
            });
            function customerPreferredContactMethodOnChange(evt:Event) {
                var v:String = (cast evt.target).value;
                var m = ContactMethod.fromId(v);
                setState({
                    editingDelivery: state.editingDelivery.with({
                        customerPreferredContactMethod: m,
                    }),
                });
            }
            jsx('
                <TextField
                    select
                    label="聯絡方法"
                    variant=${Filled}
                    InputProps=${inputProps}
                    InputLabelProps=${inputLabelProps}
                    fullWidth
                    value=${switch (d.customerPreferredContactMethod) {
                        case null: "";
                        case m: (m:String);
                    }}
                    onChange=${customerPreferredContactMethodOnChange}
                >
                    ${contactMethods}
                </TextField>
            ');
        }

        var tg = if (!state.isEditing) {
            if (d.customer.tg != null && d.customer.tg.username != null) {
                var tgUrl = "https://t.me/" + d.customer.tg.username;
                jsx('<Typography><a href=${tgUrl} target="_blank">${tgUrl}</a> ${d.customerPreferredContactMethod == Telegram ? " 👈" : ""}</Typography>');
            } else {
                null;
            }
        } else {
            var tgUsername = d.customer.tg != null && d.customer.tg.username != null ? d.customer.tg.username : "";
            function tgUsernameOnChange(evt:Event) {
                var v:String = (cast evt.target).value;
                var username = v != "" ? v : null;
                setState({
                    editingDelivery: state.editingDelivery.with({
                        customer: state.editingDelivery.customer.with({
                            tg: switch (state.editingDelivery.customer.tg) {
                                case null:
                                    ({
                                        username: username,
                                    }:Tg);
                                case tg:
                                    tg.with({
                                        username: username,
                                    });
                            }
                        }),
                    }),
                });
            }
            jsx('
                <TextField
                    label="客人Telegram"
                    variant=${Filled}
                    fullWidth
                    InputProps=${inputProps.merge({
                        startAdornment: jsx('<InputAdornment position=${Start}>@</InputAdornment>'),
                    })}
                    InputLabelProps=${inputLabelProps}
                    value=${tgUsername}
                    onChange=${tgUsernameOnChange} />
            ');
        }

        var wa = if (!state.isEditing) {
            if (d.customer.tel != null) {
                var waUrl = "https://wa.me/852" + d.customer.tel;
                jsx('<Typography><a href=${waUrl} target="_blank">${waUrl}</a> ${d.customerPreferredContactMethod == WhatsApp ? " 👈" : ""}</Typography>');
            } else {
                null;
            }
        } else {
            function telOnChange(evt:Event) {
                var v:String = (cast evt.target).value;
                var tel = v != "" ? v : null;
                setState({
                    editingDelivery: state.editingDelivery.with({
                        customer: state.editingDelivery.customer.with({
                            tel: tel,
                        }),
                    }),
                });
            }
            jsx('
                <TextField
                    label="客人WhatsApp"
                    variant=${Filled}
                    fullWidth
                    InputProps=${inputProps.merge({
                        startAdornment: jsx('<InputAdornment position=${Start}>+852</InputAdornment>'),
                    })}
                    InputLabelProps=${inputLabelProps}
                    value=${d.customer.tel != null ? d.customer.tel : ""}
                    onChange=${telOnChange} />
            ');
        }

        var paymentMethods = if (!state.isEditing) {
            jsx('<Typography>${d.paymentMethods.map(p -> p.info().name).join(", ")}</Typography>');
        } else {
            var items = [PayMe, FPS].map(m -> {
                function onChange(evt) {
                    var checked:Bool = (cast evt.target).checked;
                    setState({
                        editingDelivery: state.editingDelivery.with({
                            paymentMethods:
                                if (checked) {
                                    state.editingDelivery.paymentMethods.concat([m]);
                                } else {
                                    state.editingDelivery.paymentMethods.filter(_m -> _m != m);
                                },
                        }),
                    });
                }
                var checkbox = jsx('
                    <Checkbox
                        checked=${d.paymentMethods.has(m)}
                        onChange=${onChange}
                    />
                ');
                jsx('
                    <FormControlLabel
                        control=${checkbox}
                        label=${m.info().name}
                    />
                ');
            });
            jsx('
                <FormControl component="fieldset" className="mt-2">
                    <FormLabel component="legend" className="mb-0">付款方法</FormLabel>
                    <FormGroup row>
                        ${items}
                    </FormGroup>
                </FormControl>
            ');
        }

        var pickupLocation = if (!state.isEditing) {
            jsx('<Typography>${d.pickupLocation + " (" + d.pickupMethod.info().name + ") ($" + d.deliveryFee.nanIfNull() + ")"}</Typography>');
        } else {
            function locOnChange(evt:Event) {
                var v:String = (cast evt.target).value;
                var loc = v != "" ? v : null;
                setState({
                    editingDelivery: state.editingDelivery.with({
                        pickupLocation: loc,
                    }),
                });
            }
            function pickupMethodOnChange(evt:Event) {
                var v:String = (cast evt.target).value;
                var m = PickupMethod.fromId(v);
                setState({
                    editingDelivery: state.editingDelivery.with({
                        pickupMethod: m,
                    }),
                });
            }
            function deliveryFeeOnChange(evt:Event) {
                var v:String = (cast evt.target).value;
                var deliveryFee = Std.parseFloat(v);
                setState({
                    editingDelivery: state.editingDelivery.with({
                        deliveryFee: deliveryFee,
                    }),
                });
            }
            var pickupMethods = [Door, HangOutside, Street].map(m -> {
                jsx('<MenuItem key=${m} value=${m}>${m.info().name}</MenuItem>');
            });
            jsx('
                <Fragment>
                    <TextField
                        label="交收地點"
                        variant=${Filled}
                        fullWidth
                        InputProps=${inputProps}
                        InputLabelProps=${inputLabelProps}
                        value=${d.pickupLocation}
                        onChange=${locOnChange} />
                    <TextField
                        select
                        label="交收方法"
                        variant=${Filled}
                        InputProps=${inputProps}
                        InputLabelProps=${inputLabelProps}
                        fullWidth
                        value=${(d.pickupMethod:String)}
                        onChange=${pickupMethodOnChange}
                    >
                        ${pickupMethods}
                    </TextField>
                    <TextField
                        label="運費"
                        variant=${Filled}
                        fullWidth
                        type=${Number}
                        InputProps=${inputProps.merge({
                            startAdornment: jsx('<InputAdornment position=${Start}>$$</InputAdornment>'),
                        })}
                        InputLabelProps=${inputLabelProps}
                        value=${d.deliveryFee}
                        onChange=${deliveryFeeOnChange} />
                </Fragment>
            ');
        }

        var customerNote = if (!state.isEditing) {
            if (d.customerNote != null && d.customerNote != "") {
                jsx('<Typography>⚠️ ${d.customerNote}</Typography>');
            } else {
                null;
            }
        } else {
            function customerNoteOnChange(evt:Event) {
                var v:String = (cast evt.target).value;
                var customerNote = v != "" ? v : null;
                setState({
                    editingDelivery: state.editingDelivery.with({
                        customerNote: customerNote,
                    }),
                });
            }
            jsx('
                <TextField
                    label="運送備註"
                    variant=${Filled}
                    InputProps=${inputProps}
                    InputLabelProps=${inputLabelProps}
                    multiline
                    fullWidth
                    rowsMax=${cast Math.POSITIVE_INFINITY}
                    value=${d.customerNote != null ? d.customerNote : ""}
                    placeholder="無"
                    onChange=${customerNoteOnChange}
                />
            ');
        }

        var subheader = if (d.couriers == null) {
            null;
        } else {
            var couriers = d.couriers.map(c -> jsx('
                <Grid item key=${c.tg.username}><a href=${"https://t.me/" + c.tg.username} target="_blank">@${c.tg.username}</a></Grid>
            '));
            jsx('
                <Grid container wrap=${NoWrap} spacing=${Spacing_1}>${couriers}</Grid>
            ');
        }

        var actions = if (state.isEditing) {
            jsx('
                <CardActions className="d-flex">
                    <Button
                        variant=${Contained}
                        color=${Primary}
                        size=${Small}
                        onClick=${evt -> onSave()}
                    >
                        Save
                    </Button>
                    <Button
                        size=${Small}
                        onClick=${evt -> onCancel()}
                    >
                        Cancel
                    </Button>
                    <Button
                        className="ml-auto"
                        size=${Small}
                        color=${Secondary}
                        onClick=${evt -> onDelete()}
                    >
                        Delete
                    </Button>
                </CardActions>
            ');
        } else {
            jsx('
                <CardActions>
                    <Button size=${Small} onClick=${evt -> onEdit()}>Edit</Button>
                </CardActions>
            ');
        }

        return jsx('
            <Card className="delivery-card" elevation=${state.isEditing ? 5 : 1}>
                <CardHeader
                    title=${"📃 " + d.deliveryCode}
                    subheader=${subheader}
                />
                <CardContent>
                    ${d.orders.mapi(renderOrder)}

                    <Typography paragraph>總食物價錢+運費: $$${foodTotal + d.deliveryFee.nanIfNull()}</Typography>

                    <Typography>${d.pickupTimeSlot.print()}</Typography>
                    ${customerPreferredContactMethod}
                    ${tg}
                    ${wa}
                    ${paymentMethods}
                    ${pickupLocation}
                    ${customerNote}
                </CardContent>
                ${actions}
            </Card>
        ');
    }
}